/****************************************************************************
 * arch/arm/src/stm32h5/hardware/stm32_exti.h
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

#ifndef __ARCH_ARM_SRC_STM32H5_HARDWARE_STM32_EXTI_H
#define __ARCH_ARM_SRC_STM32H5_HARDWARE_STM32_EXTI_H

/****************************************************************************
 * Included Files
 ****************************************************************************/

#include <nuttx/config.h>
#include "chip.h"
#include "hardware/stm32_memorymap.h"

/* Content of this file requires verification before it is used with other
 * families
 */

#if defined(CONFIG_STM32H5_STM32H5XXXX)

/****************************************************************************
 * Pre-processor Definitions
 ****************************************************************************/

/* Register Offsets *********************************************************/

#define STM32_EXTI_RTSR1_OFFSET      0x0000  /* Rising Trigger Selection 1       */
#define STM32_EXTI_FTSR1_OFFSET      0x0004  /* Falling Trigger Selection 1      */
#define STM32_EXTI_SWIER1_OFFSET     0x0008  /* Software Interrupt Event 1       */
#define STM32_EXTI_RPR1_OFFSET       0x000c  /* Rising Edge Pending 1            */
#define STM32_EXTI_FPR1_OFFSET       0x0010  /* Falling Edge Pending 1           */
#define STM32_EXTI_SECCFGR1_OFFSET   0x0014  /* Security Configuration 1         */
#define STM32_EXTI_PRIVCFGR1_OFFSET  0x0018  /* Privilege Configuration 1        */
#define STM32_EXTI_RTSR2_OFFSET      0x0020  /* Rising Trigger Selection 2       */
#define STM32_EXTI_FTSR2_OFFSET      0x0024  /* Falling Trigger Selection 2      */
#define STM32_EXTI_SWIER2_OFFSET     0x0028  /* Software Interrupt Event 2       */
#define STM32_EXTI_RPR2_OFFSET       0x002c  /* Rising Edge Pending 2            */
#define STM32_EXTI_FPR2_OFFSET       0x0030  /* Falling Edge Pending 2           */
#define STM32_EXTI_SECCFGR2_OFFSET   0x0034  /* Security Configuration 2         */
#define STM32_EXTI_PRIVCFGR2_OFFSET  0x0038  /* Privilege Configuration 2        */
#define STM32_EXTI_EXTICR1_OFFSET    0x0060  /* External Interrupt Selection 1   */
#define STM32_EXTI_EXTICR2_OFFSET    0x0064  /* External Interrupt Selection 2   */
#define STM32_EXTI_EXTICR3_OFFSET    0x0068  /* External Interrupt Selection 3   */
#define STM32_EXTI_EXTICR4_OFFSET    0x006c  /* External Interrupt Selection 4   */
#define STM32_EXTI_LOCKR_OFFSET      0x0070  /* Lock                             */
#define STM32_EXTI_IMR1_OFFSET       0x0080  /* CPU Wakeup with Interrupt Mask 1 */
#define STM32_EXTI_EMR1_OFFSET       0x0084  /* CPU Wakeup with Event Mask 1     */
#define STM32_EXTI_IMR2_OFFSET       0x0090  /* CPU Wakeup with Interrupt Mask 2 */
#define STM32_EXTI_EMR2_OFFSET       0x0094  /* CPU Wakeup with Event Mask 2     */

/* Register Addresses *******************************************************/

#define STM32_EXTI_RTSR1      (STM32_EXTI_BASE + STM32_EXTI_RTSR1_OFFSET)
#define STM32_EXTI_FTSR1      (STM32_EXTI_BASE + STM32_EXTI_FTSR1_OFFSET)
#define STM32_EXTI_SWIER1     (STM32_EXTI_BASE + STM32_EXTI_SWIER1_OFFSET)
#define STM32_EXTI_RPR1       (STM32_EXTI_BASE + STM32_EXTI_RPR1_OFFSET)
#define STM32_EXTI_FPR1       (STM32_EXTI_BASE + STM32_EXTI_FPR1_OFFSET)
#define STM32_EXTI_SECCFGR1   (STM32_EXTI_BASE + STM32_EXTI_SECCFGR1_OFFSET)
#define STM32_EXTI_PRIVCFGR1  (STM32_EXTI_BASE + STM32_EXTI_PRIVCFGR1_OFFSET)
#define STM32_EXTI_RTSR2      (STM32_EXTI_BASE + STM32_EXTI_RTSR2_OFFSET)
#define STM32_EXTI_FTSR2      (STM32_EXTI_BASE + STM32_EXTI_FTSR2_OFFSET)
#define STM32_EXTI_SWIER2     (STM32_EXTI_BASE + STM32_EXTI_SWIER2_OFFSET)
#define STM32_EXTI_RPR2       (STM32_EXTI_BASE + STM32_EXTI_RPR2_OFFSET)
#define STM32_EXTI_FPR2       (STM32_EXTI_BASE + STM32_EXTI_FPR2_OFFSET)
#define STM32_EXTI_SECCFGR2   (STM32_EXTI_BASE + STM32_EXTI_SECCFGR2_OFFSET)
#define STM32_EXTI_PRIVCFGR2  (STM32_EXTI_BASE + STM32_EXTI_PRIVCFGR2_OFFSET)
#define STM32_EXTI_EXTICR1    (STM32_EXTI_BASE + STM32_EXTI_EXTICR1_OFFSET)
#define STM32_EXTI_EXTICR2    (STM32_EXTI_BASE + STM32_EXTI_EXTICR2_OFFSET)
#define STM32_EXTI_EXTICR3    (STM32_EXTI_BASE + STM32_EXTI_EXTICR3_OFFSET)
#define STM32_EXTI_EXTICR4    (STM32_EXTI_BASE + STM32_EXTI_EXTICR4_OFFSET)
#define STM32_EXTI_LOCKR      (STM32_EXTI_BASE + STM32_EXTI_LOCKR_OFFSET)
#define STM32_EXTI_IMR1       (STM32_EXTI_BASE + STM32_EXTI_IMR1_OFFSET)
#define STM32_EXTI_EMR1       (STM32_EXTI_BASE + STM32_EXTI_EMR1_OFFSET)
#define STM32_EXTI_IMR2       (STM32_EXTI_BASE + STM32_EXTI_IMR2_OFFSET)
#define STM32_EXTI_EMR2       (STM32_EXTI_BASE + STM32_EXTI_EMR2_OFFSET)

/* Register Bitfield Definitions ********************************************/

/* EXTI event input mapping *************************************************/

#define EXTI_EVENT_EXTI(n)          (1 << (n) /* 0-15 EXTI[15:0] */
#define EXTI_EVENT_PVDAVD           16        /* PVD and AVD */
#define EXTI_EVENT_RTC              17        /* RTC non-secure */
#define EXTI_EVENT_RTC_SECURE       18        /* RTC secure */
#define EXTI_EVENT_TAMP             19        /* Tamper non-secure */
#define EXTI_EVENT_TAMP_SECURE      20        /* Tamper secure */
#define EXTI_EVENT_I2C1             21        /* I2C1 wakeup */
#define EXTI_EVENT_I2C2             22        /* I2C2 wakeup */
#define EXTI_EVENT_I2C3             23        /* I2C3 wakeup */
#define EXTI_EVENT_I3C1             24        /* I3C1 wakeup */
#define EXTI_EVENT_USART1           25        /* USART1 wakeup */
#define EXTI_EVENT_USART2           26        /* USART2 wakeup */
#define EXTI_EVENT_USART3           27        /* USART3 wakeup */
#define EXTI_EVENT_UART4            28        /* UART4 wakeup */
#define EXTI_EVENT_UART5            29        /* UART5 wakeup */
#define EXTI_EVENT_USART6           30        /* USART6 wakeup */
#define EXTI_EVENT_UART7            31        /* UART7 wakeup */
#define EXTI_EVENT_UART8            32        /* UART8 wakeup */
#define EXTI_EVENT_UART9            33        /* UART9 wakeup */
#define EXTI_EVENT_UART10           34        /* UART10 wakeup */
#define EXTI_EVENT_UART11           35        /* UART11 wakeup */
#define EXTI_EVENT_UART12           36        /* UART12 wakeup */
#define EXTI_EVENT_LPUART1          37        /* LPUART1 wakeup */
#define EXTI_EVENT_LPTIM1           38        /* LPTIM1 */
#define EXTI_EVENT_LPTIM2           39        /* LPTIM2 */
#define EXTI_EVENT_SPI1             40        /* SPI1 wakeup */
#define EXTI_EVENT_SPI2             41        /* SPI2 wakeup */
#define EXTI_EVENT_SPI3             42        /* SPI3 wakeup */
#define EXTI_EVENT_SPI4             43        /* SPI4 wakeup */
#define EXTI_EVENT_SPI5             44        /* SPI5 wakeup */
#define EXTI_EVENT_SPI6             45        /* SPI6 wakeup */
#define EXTI_EVENT_ETH              46        /* Ethernet wakeup */
#define EXTI_EVENT_USBFS            47        /* USB FS wakeup */
#define EXTI_EVENT_USBPD1           48        /* USBPD1 wakeup */
#define EXTI_EVENT_LPTIM2CH1        49        /* LPTIM2 CH1 wakeup */
#define EXTI_EVENT_DTSWKUP          50        /* DTS wakeup */
#define EXTI_EVENT_CECWKUP          51        /* HDMI-CEC wakeup */
#define EXTI_EVENT_I2C4WKUP         52        /* I2C4 wakeup */
#define EXTI_EVENT_VDDIO2           53        /* VDDIO2 monitoring */
#define EXTI_EVENT_LPTIM3           54        /* LPTIM3 */
#define EXTI_EVENT_LPTIM4           55        /* LPTIM4 */
#define EXTI_EVENT_LPTIM5           56        /* LPTIM5 */
#define EXTI_EVENT_LPTIM6           57        /* LPTIM6 */
#define EXTI_EVENT_I3C2             58        /* I3C2 */

#endif /* CONFIG_STM32H5_STM32H5XXXX */
#endif /* __ARCH_ARM_SRC_STM32H5_HARDWARE_STM32_EXTI_H */
