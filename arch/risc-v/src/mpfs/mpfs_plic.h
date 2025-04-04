/****************************************************************************
 * arch/risc-v/src/mpfs/mpfs_plic.h
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

#ifndef __ARCH_RISC_V_SRC_MPFS_MPFS_PLIC_H
#define __ARCH_RISC_V_SRC_MPFS_MPFS_PLIC_H

/****************************************************************************
 * Included Files
 ****************************************************************************/

#include <stdint.h>

/****************************************************************************
 * Public Function Prototypes
 ****************************************************************************/

/****************************************************************************
 * Name: mpfs_plic_init_hart
 *
 * Description:
 *   Initialize current hart's PLIC.
 *
 * Input Parameters:
 *   hartid - Hart ID to init.
 *
 * Returned Value:
 *   None.
 *
 ****************************************************************************/

void mpfs_plic_init_hart(uintptr_t hartid);

/****************************************************************************
 * Name: mpfs_plic_get_iebase
 *
 * Description:
 *   Context aware way to query PLIC interrupt enable base address
 *
 * Returned Value:
 *   Interrupt enable base address
 *
 ****************************************************************************/

uintptr_t mpfs_plic_get_iebase(uintptr_t hartid);

/****************************************************************************
 * Name: mpfs_plic_get_claimbase
 *
 * Description:
 *   Context aware way to query PLIC interrupt claim base address
 *
 * Returned Value:
 *   Interrupt enable claim address
 *
 ****************************************************************************/

uintptr_t mpfs_plic_get_claimbase(uintptr_t hartid);

/****************************************************************************
 * Name: mpfs_plic_get_thresholdbase
 *
 * Description:
 *   Context aware way to query PLIC interrupt threshold base address
 *
 * Returned Value:
 *   Interrupt enable threshold address
 *
 ****************************************************************************/

uintptr_t mpfs_plic_get_thresholdbase(void);

/****************************************************************************
 * Name: mpfs_plic_disable_irq(int extirq)
 *
 * Description:
 *   Disable interrupt on all harts
 *
 * Returned Value:
 *   None
 *
 ****************************************************************************/

void mpfs_plic_disable_irq(int extirq);

/****************************************************************************
 * Name: mpfs_plic_clear_and_enable_irq
 *
 * Description:
 *   Enable interrupt; if it is pending, clear it first
 *
 * Returned Value:
 *   None
 *
 ****************************************************************************/

void mpfs_plic_clear_and_enable_irq(int extirq);

#endif /* __ARCH_RISC_V_SRC_MPFS_MPFS_PLIC_H */
