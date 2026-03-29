# SPI To UART

This repo contains the code for a FPGA to read a SPI sensor and output the message in UART. In this case, a Basys 3 with a [SPI ambient light sensor](https://digilent.com/reference/pmod/pmodals/start) (ALS).
The main parts of this project is the SPI controller, the UART controller, and the clock domain crossing (CDC) FIFO interlink. While this project doesn't need CDC logic since both can be implemented with integer clock dividers, I wanted to learn about it and test it so they use differing clocks.

# Design

## SPI Controller

## UART Controller

## AFIFO

# How to Run

1. Clone this repository
2. Open repository in Xillinx Vivado and import all files
3. Build and Run with default settings

# Example Output

![](docs/adc_data.png?raw=true)
