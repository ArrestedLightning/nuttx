# USB CDC UART Startup Trace

This trace follows the `nucleo-f072rb:usb-cdc-uart` configuration. The
USART2/ST-Link console remains the NSH and syslog channel. CDC ACM is a
separate USB device registered during board late initialization.

## Reset To Controller Setup

1. [arch/arm/src/common/stm32/stm32_start_m0_v1.c](../../../../../../arch/arm/src/common/stm32/stm32_start_m0_v1.c)
   - `__start()` is entered from the reset vector.
   - Calls `stm32_clockconfig()` and `stm32_lowsetup()`.
   - The `A` through `F` characters come from `showprogress()` in this file.
   - Calls `stm32_boardinitialize()` and then `nx_start()`.

2. [sched/init/nx_bringup.c](../../../../../../sched/init/nx_bringup.c)
   - NuttX startup calls architecture initialization, including `up_initialize()`.
   - Later, `nx_start_application()` calls `board_late_initialize()` because
     `CONFIG_BOARD_LATE_INITIALIZE=y`.

3. [arch/arm/src/common/arm_initialize.c](../../../../../../arch/arm/src/common/arm_initialize.c)
   - `up_initialize()` initializes the serial driver first.
   - Because `CONFIG_USBDEV=y`, it calls `arm_usbinitialize()`.

4. [arch/arm/src/common/stm32/stm32_usbdev_m0_v1.c](../../../../../../arch/arm/src/common/stm32/stm32_usbdev_m0_v1.c)
   - `arm_usbinitialize()` configures `GPIO_USB_DM` and `GPIO_USB_DP`.
   - Calls `stm32_hwsetup()`.
   - Attaches `stm32_usb_interrupt()` to `STM32_IRQ_USB`.
   - Does not enable the NVIC USB interrupt yet.
   - Does not enable D+ pull-up yet.

5. [boards/arm/stm32f0/nucleo-f072rb/src/stm32_boot.c](../../src/stm32_boot.c)
   - `stm32_usbpullup(..., false)` is called from `stm32_hwsetup()`.
   - This clears `USB_BCDR.DPPU` while the controller is prepared.

## CDC Class Registration

6. [boards/arm/stm32f0/nucleo-f072rb/src/stm32_bringup.c](../../src/stm32_bringup.c)
    - `stm32_bringup()` calls `cdcacm_initialize(0, NULL)`, registering CDC
       ACM and attaching D+ during board late initialization.

7. [external/TwoGUsbDiag/2g-usb-diagnostics/2g_usb_diagnostics_main.c](../../../../../../../apps/external/TwoGUsbDiag/2g-usb-diagnostics/2g_usb_diagnostics_main.c)
    - `two_g_usb_diagnostics arm` clears and enables the trace ring without
       changing the CDC connection.
    - `two_g_usb_diagnostics stop` clears D+ to detach from the host while
       retaining the registered CDC class and `/dev/ttyACM0`.
    - `start` re-arms tracing and reattaches D+ when needed. `reconnect`
       detaches D+ for 250 ms and reattaches it to trigger enumeration.
    - `status` reports the CDC node, D+ state, trace state, and last action
       without consuming trace records.

8. [drivers/usbdev/cdcacm.c](../../../../../../drivers/usbdev/cdcacm.c)

    - `cdcacm_initialize()` creates the standalone CDC ACM class object with
       `cdcacm_classobject()` and calls `usbdev_register(drvr)`.
    - `cdcacm_bind()` is the class callback invoked by the controller. It
       allocates EP0 requests and reserves the CDC endpoints.

9. [arch/arm/src/common/stm32/stm32_usbdev_m0_v1.c](../../../../../../arch/arm/src/common/stm32/stm32_usbdev_m0_v1.c)
   - `usbdev_register()` stores `priv->driver`.
   - `CLASS_BIND(driver, &priv->usbdev)` invokes `cdcacm_bind()`.
   - `stm32_hwreset()` initializes EP0, clears USB status, and enables the
     controller masks in `STM32_CNTR_SETUP`.
   - `up_enable_irq(STM32_IRQ_USB)` enables the global USB IRQ in the NVIC.
   - `stm32_usbpullup(..., true)` sets `USB_BCDR.DPPU`.

## Host Enumeration

10. [arch/arm/src/common/stm32/stm32_usbdev_m0_v1.c](../../../../../../arch/arm/src/common/stm32/stm32_usbdev_m0_v1.c)
    - `stm32_usb_interrupt()` is the global STM32F072 USB ISR.
    - `STM32_IRQ_USB` is external interrupt 31, represented by NuttX IRQ 47.
    - A host reset sets `USB_ISTR_RESET` and calls `stm32_reset()`.
    - A successful EP0 transaction sets `USB_ISTR_CTR`; endpoint 0 reaches
      `stm32_ep0done()` and then `stm32_ep0setup()`.
    - `stm32_ep0setup()` decodes the eight-byte SETUP request and calls
      `stm32_dispatchrequest()` for descriptors and CDC class requests.
    - `stm32_dispatchrequest()` invokes `cdcacm_setup()` through `CLASS_SETUP`.

11. [drivers/usbdev/cdcacm.c](../../../../../../drivers/usbdev/cdcacm.c)
    - `cdcacm_setup()` serves the device, configuration, and string
      descriptors for standalone CDC ACM.
    - `SET_CONFIGURATION` calls `cdcacm_setconfig()`, which configures the
      bulk and interrupt endpoints and queues bulk OUT receive requests.

## Suggested Debug Stops

Use one hardware breakpoint at a time on Cortex-M0:

1. `arm_usbinitialize` confirms early GPIO and IRQ attachment.
2. `usbdev_register` confirms class binding, EP0 setup, NVIC enable, and D+.
3. `stm32_usbpullup` confirms writes to `USB_BCDR.DPPU`.
4. `stm32_usb_interrupt` proves a host event reaches the NuttX vector.
5. `stm32_ep0done` proves a completed EP0 bus transaction.
6. `stm32_ep0setup` reveals the raw host SETUP request.
7. `cdcacm_setup` identifies descriptor or CDC class acceptance/rejection.

At `stm32_usb_interrupt`, inspect `STM32_USB_ISTR`, `STM32_USB_CNTR`,
`STM32_USB_DADDR`, and `STM32_USB_EPR(0)`. At `stm32_ep0setup`, inspect
`priv->ctrl.type`, `priv->ctrl.req`, `priv->ctrl.value`, `priv->ctrl.index`,
and `priv->ctrl.len`.