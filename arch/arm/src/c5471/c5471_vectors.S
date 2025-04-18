/****************************************************************************
 * arch/arm/src/c5471/c5471_vectors.S
 *
 * SPDX-License-Identifier: Apache-2.0
 *
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.  The
 * ASF licenses this file to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance with the
 * License.  You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.  See the
 * License for the specific language governing permissions and limitations
 * under the License.
 *
 ****************************************************************************/

/****************************************************************************
 * Included Files
 ****************************************************************************/

#include <nuttx/config.h>
#include <nuttx/irq.h>

#include "arm.h"
#include "chip.h"

/****************************************************************************
 * Pre-processor Definitions
 ****************************************************************************/

/****************************************************************************
 * Public Data
 ****************************************************************************/

	.data
g_irqtmp:
	.word	0		/* Saved lr */
	.word	0		/* Saved spsr */
g_undeftmp:
	.word	0		/* Saved lr */
	.word	0		/* Saved spsr */
g_aborttmp:
	.word	0		/* Saved lr */
	.word	0		/* Saved spsr */

/****************************************************************************
 * Assembly Macros
 ****************************************************************************/

/****************************************************************************
 * Private Functions
 ****************************************************************************/

	.text

/****************************************************************************
 * Public Functions
 ****************************************************************************/

	.text

/****************************************************************************
 * Name: arm_vectorirq
 *
 * Description:
 *   Interrupt exception. Entered in IRQ mode with spsr = SVC
 *   CPSR, lr = SVC PC
 ****************************************************************************/

	.globl	arm_vectorirq
	.type	arm_vectorirq, %function
arm_vectorirq:
	/* On entry, we are in IRQ mode.  We are free to use
	 * the IRQ mode r13 and r14.
	 *
	 */

	ldr	r13, .Lirqtmp
	sub	lr, lr, #4
	str	lr, [r13]		/* Save lr_IRQ */
	mrs	lr, spsr
	str	lr, [r13, #4]		/* Save spsr_IRQ */

	/* Then switch back to SYS mode */

	bic	lr, lr, #PSR_MODE_MASK	/* Keep F and T bits */
	orr	lr, lr, #(PSR_MODE_SYS | PSR_I_BIT)
	msr	cpsr_c, lr		/* Switch to SYS mode */

	/* Create a context structure.  First set aside a stack frame
	 * and store r0-r12 into the frame.
	 */

	sub	sp, sp, #XCPTCONTEXT_SIZE
	stmia	sp, {r0-r12}		/* Save the SYS mode regs */

	/* Get the correct values of r13(sp) and r14(lr) in r1 and r2 */

	add	r1, sp, #XCPTCONTEXT_SIZE
	mov	r2, r14

	/* Get the values for r15(pc) and CPSR in r3 and r4 */

	ldr	r0, .Lirqtmp		/* Points to temp storage */
	ldmia	r0, {r3, r4}		/* Recover r1=lr_IRQ, r2=spsr_IRQ */

	add	r0, sp, #(4*REG_SP)	/* Offset to pc, cpsr storage */
	stmia	r0, {r1-r4}

	/* Now decode the interrupt */

#if 0
	ldr	lr, =SRC_IRQ_BIN_REG	/* Fetch encoded IRQ */
	ldr	r0, [lr]
	and	r0, r0, #0x0f		/* Valid range is 0..15 */

	/* Problems here... cannot read SRC_IRQ_BIN_REQ (and/or
	 * SRC_IRQ_REQ because this will clear edge triggered
	 * interrupts.  Plus, no way to validate spurious
	 * interrupt.
	 */
#else
	ldr	r6, =SRC_IRQ_REG
	ldr	r6, [r6]		/* Get source IRQ reg */
	mov	r0, #0			/* Assume IRQ0_IRQ set */
.Lmorebits:
	tst	r6, #1			/* Is IRQ set? */
	bne	.Lhaveirq		/* Yes... we have the IRQ */
	add	r0, r0, #1		/* Setup next IRQ */
	mov	r6, r6, lsr #1		/* Shift right one */
	cmp	r0, #16			/* Only 16 valid bits */
	bcc	.Lmorebits		/* Keep until we have looked
					 * at all bits */
	b	.Lnoirqset		/* If we get here, there is
					 * no pending interrupt */
.Lhaveirq:
#endif
	/* Then call the IRQ handler with interrupt disabled. */

	mov	fp, #0			/* Init frame pointer */
	mov	r1, sp			/* Get r1=xcp */

#if CONFIG_ARCH_INTERRUPTSTACK > 3
	ldr	sp, .Lirqstacktop	/* SP = interrupt stack top */
	str	r1, [sp, #-4]!		/* Save the xcp address at SP-4 then update SP */
	bl	arm_doirq		/* Call the handler */
	ldr	sp, [sp]		/* Restore the user stack pointer */
#else
	/* If the interrupt stack is disabled, reserve xcpcontext to ensure
	 * that signal processing can have a separate xcpcontext to handle
	 * signal context (reference: arm_schedulesigaction.c):
	 *      ----------------------
	 *     |    IRQ XCP context   |
	 *      -------------------
	 *     |  Signal XCP context  |
	 *      ----------------------   <- SP
	 */

	sub	sp, sp, #XCPTCONTEXT_SIZE	/* Reserve signal context */

	bl	arm_doirq			/* Call the handler */

	add	sp, sp, #XCPTCONTEXT_SIZE	/* Restore signal context */
#endif

	/* Restore the CPSR, SYS mode registers and return */
.Lnoirqset:
	ldr	r0, [sp, #(4*REG_CPSR)]	/* Setup the SYS mode SPSR */
	msr	spsr_cxsf, r0
	ldmia	sp, {r0-r15}^		/* Return */

.Lirqtmp:
	.word	g_irqtmp
#if CONFIG_ARCH_INTERRUPTSTACK > 3
.Lirqstacktop:
	.word	g_intstacktop
#endif
	.align	5

/****************************************************************************
 * Function: arm_vectorsvc
 *
 * Description:
 *   SWI interrupt. We enter the SWI in SYS mode
 ****************************************************************************/

	.globl	arm_vectorsvc
	.type	arm_vectorsvc, %function
arm_vectorsvc:

	/* The c547x rrload bootloader intemediates all
	 * interrupts.  For the* case of the SWI, it mucked
	 * with the stack to create some temporary registers.
	 * We'll have to recover from this mucking here.
	 */

	ldr	r14, [sp,#-0x4]		/* rrload workaround */

	/* Create a context structure.  First set aside a stack frame
	 * and store r0-r12 into the frame.
	 */

	sub	sp, sp, #XCPTCONTEXT_SIZE
	stmia	sp, {r0-r12}		/* Save the SYS mode regs */

	/* Get the correct values of r13(sp), r14(lr), r15(pc)
	 * and CPSR in r1-r4 */

	add	r1, sp, #XCPTCONTEXT_SIZE
	mov	r2, r14			/* R14 is altered on return from SWI */
	mov	r3, r14			/* Save r14 as the PC as well */
	mrs	r4, spsr		/* Get the saved CPSR */

	add	r0, sp, #(4*REG_SP)	/* Offset to pc, cpsr storage */
	stmia	r0, {r1-r4}

	/* Then call the SWI handler with interrupt disabled.
	 * void arm_syscall(struct xcptcontext *xcp)
	 */

	mov	fp, #0			/* Init frame pointer */
	mov	r0, sp			/* Get r0=xcp */
	bl	arm_syscall		/* Call the handler */

	/* Restore the CPSR, SYS mode registers and return */

	ldr	r0, [sp, #(4*REG_CPSR)]	/* Setup the SYS mode SPSR */
	msr	spsr_cxsf, r0
	ldmia	sp, {r0-r15}^		/* Return */

	.align	5

/****************************************************************************
 * Name: arm_vectordata
 *
 * Description:
 *   Data abort Exception dispatcher. Give control to data
 *   abort handler.  This function is entered in ABORT mode
 *   with spsr = SVC CPSR, lr = SVC PC
 *
 ****************************************************************************/

	.globl	arm_vectordata
	.type	arm_vectordata, %function
arm_vectordata:
	/* On entry we are free to use the ABORT mode registers
	 * r13 and r14
	 */

	ldr	r13, .Ldaborttmp	/* Points to temp storage */
	sub	lr, lr, #8		/* Fixup return */
	str	lr, [r13]		/* Save in temp storage */
	mrs	lr, spsr		/* Get SPSR */
	str	lr, [r13, #4]		/* Save in temp storage */

	/* Then switch back to SYS mode */

	bic	lr, lr, #PSR_MODE_MASK	/* Keep F and T bits */
	orr	lr, lr, #(PSR_MODE_SYS | PSR_I_BIT)
	msr	cpsr_c, lr		/* Switch to SYS mode */

	/* Create a context structure.  First set aside a stack frame
	 * and store r0-r12 into the frame.
	 */

	sub	sp, sp, #XCPTCONTEXT_SIZE
	stmia	sp, {r0-r12}		/* Save the SYS mode regs */

	/* Get the correct values of r13(sp) and r14(lr) in r1 and r2 */

	add	r1, sp, #XCPTCONTEXT_SIZE
	mov	r2, r14

	/* Get the values for r15(pc) and CPSR in r3 and r4 */

	ldr	r0, .Ldaborttmp		/* Points to temp storage */
	ldmia	r0, {r3, r4}		/* Recover r1=lr_IRQ, r2=spsr_IRQ */

	add	r0, sp, #(4*REG_SP)	/* Offset to pc, cpsr storage */
	stmia	r0, {r1-r4}

	/* Then call the data abort handler with interrupts disabled.
	 * void arm_dataabort(struct xcptcontext *xcp)
	 */

	mov	fp, #0			/* Init frame pointer */
	mov	r0, sp			/* Get r0=xcp */
	bl	arm_dataabort		/* Call the handler */

	/* Restore the CPSR, SYS mode registers and return */

	ldr	r0, [sp, #(4*REG_CPSR)]	/* Setup the SYS mode SPSR */
	msr	spsr_cxsf, r0
	ldmia	sp, {r0-r15}^		/* Return */

.Ldaborttmp:
	.word	g_aborttmp

	.align	5

/****************************************************************************
 * Name: arm_vectorprefetch
 *
 * Description:
 *    Prefetch abort exception.  Entered in ABT mode with
 *    spsr = SVC CPSR, lr = SVC PC
 ****************************************************************************/

	.globl	arm_vectorprefetch
	.type	arm_vectorprefetch, %function
arm_vectorprefetch:
	/* On entry we are free to use the ABORT mode registers
	 * r13 and r14
	 */

	ldr	r13, .Lpaborttmp	/* Points to temp storage */
	sub	lr, lr, #4		/* Fixup return */
	str	lr, [r13]		/* Save in temp storage */
	mrs	lr, spsr		/* Get SPSR */
	str	lr, [r13, #4]		/* Save in temp storage */

	/* Then switch back to SYS mode */

	bic	lr, lr, #PSR_MODE_MASK	/* Keep F and T bits */
	orr	lr, lr, #(PSR_MODE_SYS | PSR_I_BIT)
	msr	cpsr_c, lr		/* Switch to SYS mode */

	/* Create a context structure.  First set aside a stack frame
	 * and store r0-r12 into the frame.
	 */

	sub	sp, sp, #XCPTCONTEXT_SIZE
	stmia	sp, {r0-r12}		/* Save the SYS mode regs */

	/* Get the correct values of r13(sp) and r14(lr) in r1 and r2 */

	add	r1, sp, #XCPTCONTEXT_SIZE
	mov	r2, r14

	/* Get the values for r15(pc) and CPSR in r3 and r4 */

	ldr	r0, .Lpaborttmp		/* Points to temp storage */
	ldmia	r0, {r3, r4}		/* Recover r1=lr_IRQ, r2=spsr_IRQ */

	add	r0, sp, #(4*REG_SP)	/* Offset to pc, cpsr storage */
	stmia	r0, {r1-r4}

	/* Then call the prefetch abort handler with interrupts disabled.
	 * void arm_prefetchabort(struct xcptcontext *xcp)
	 */

	mov	fp, #0			/* Init frame pointer */
	mov	r0, sp			/* Get r0=xcp */
	bl	arm_prefetchabort	/* Call the handler */

	/* Restore the CPSR, SYS mode registers and return */

	ldr	r0, [sp, #(4*REG_CPSR)]	/* Setup the SYS mode SPSR */
	msr	spsr_cxsf, r0
	ldmia	sp, {r0-r15}^		/* Return */

.Lpaborttmp:
	.word	g_aborttmp

	.align	5

/****************************************************************************
 * Name: arm_vectorundefinsn
 *
 * Description:
 *   Undefined instruction entry exception.  Entered in
 *   UND mode, spsr = SVC  CPSR, lr = SVC PC
 *
 ****************************************************************************/

	.globl	arm_vectorundefinsn
	.type	arm_vectorundefinsn, %function
arm_vectorundefinsn:
	/* On entry we are free to use the UND mode registers
	 * r13 and r14
	 */

	ldr	r13, .Lundeftmp		/* Points to temp storage */
	str	lr, [r13]		/* Save in temp storage */
	mrs	lr, spsr		/* Get SPSR */
	str	lr, [r13, #4]		/* Save in temp storage */

	/* Then switch back to SYS mode */

	bic	lr, lr, #PSR_MODE_MASK	/* Keep F and T bits */
	orr	lr, lr, #(PSR_MODE_SYS | PSR_I_BIT)
	msr	cpsr_c, lr		/* Switch to SYS mode */

	/* Create a context structure.  First set aside a stack frame
	 * and store r0-r12 into the frame.
	 */

	sub	sp, sp, #XCPTCONTEXT_SIZE
	stmia	sp, {r0-r12}		/* Save the SYS mode regs */

	/* Get the correct values of r13(sp) and r14(lr) in r1 and r2 */

	add	r1, sp, #XCPTCONTEXT_SIZE
	mov	r2, r14

	/* Get the values for r15(pc) and CPSR in r3 and r4 */

	ldr	r0, .Lundeftmp		/* Points to temp storage */
	ldmia	r0, {r3, r4}		/* Recover r1=lr_IRQ, r2=spsr_IRQ */

	add	r0, sp, #(4*REG_SP)	/* Offset to pc, cpsr storage */
	stmia	r0, {r1-r4}

	/* Then call the undef insn handler with interrupts disabled.
	 * void arm_undefinedinsn(struct xcptcontext *xcp)
	 */

	mov	fp, #0			/* Init frame pointer */
	mov	r0, sp			/* Get r0=xcp */
	bl	arm_undefinedinsn	/* Call the handler */

	/* Restore the CPSR, SYS mode registers and return */

	ldr	r0, [sp, #(4*REG_CPSR)]	/* Setup the SYS mode SPSR */
	msr	spsr_cxsf, r0
	ldmia	sp, {r0-r15}^		/* Return */

.Lundeftmp:
	.word	g_undeftmp

	.align	5

/****************************************************************************
 * Name: arm_vectorfiq
 *
 * Description:
 *   Shouldn't happen
 *
 ****************************************************************************/

	.globl	arm_vectorfiq
	.type	arm_vectorfiq, %function

arm_vectorfiq:
	subs	pc, lr, #4

/****************************************************************************
 *  Name: up_vectoraddrexcption
 *
 * Description:
 *   Shouldn't happen
 *
 ****************************************************************************/

	.globl	arm_vectoraddrexcptn
	.type	arm_vectoraddrexcptn, %function
arm_vectoraddrexcptn:
	b	arm_vectoraddrexcptn

/****************************************************************************
 *  Name: g_intstackalloc/g_intstacktop
 *
 * Description:
 *   Shouldn't happen
 *
 ****************************************************************************/

#if CONFIG_ARCH_INTERRUPTSTACK > 3
	.bss
	.balign	4
	.global	g_intstackalloc
	.global	g_intstacktop
	.type	g_intstackalloc, object
	.type	g_intstacktop, object

g_intstackalloc:
	.skip	(CONFIG_ARCH_INTERRUPTSTACK & ~3)
g_intstacktop:
	.size	g_intstacktop, 0
	.size	g_intstackalloc, (CONFIG_ARCH_INTERRUPTSTACK & ~3)

#endif
	.end
