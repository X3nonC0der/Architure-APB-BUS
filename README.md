# APB Bus with GPIO and UART Controller
[![Generic badge](https://img.shields.io/badge/verilog-1.0.0-red.svg)](https://shields.io/)
[![Generic badge](https://img.shields.io/badge/license-MIT-blue.svg)](https://shields.io/)
[![Generic badge](https://img.shields.io/badge/author-David%20Ayman-orange.svg)](https://shields.io/)


This project is an implementation of an Advanced Peripheral Bus (APB) with a General-Purpose Input/Output (GPIO) controller and a Universal Asynchronous Receiver/Transmitter (UART) controller.

The APB is a simple bus used to connect peripherals to the processor in a system-on-chip (SoC) design. It is used to transfer data and control signals between the processor and the peripherals.

The GPIO controller allows the processor to control and read the state of a set of digital input/output pins. The UART controller is used to send and receive data serially over a communication channel.


## Files
The project includes the following files:

- `APB_BUS.v`: Implementation of the APB bus.
- `APB_Protocol.v`: Implementation of the APB protocol.
- `GPIO.v`: Implementation of the GPIO module.
- `UART-APB-interface.v`: Implementation of the UART-APB interface.
- `UART-controller.v`: Implementation of the UART controller.
- `APB_MAIN_TB.v`: Testbench for the APB bus.

