# SPI To UART

This repo contains the code for a FPGA to read a SPI sensor and output the message in UART. In this case, a Basys 3 with a [SPI ambient light sensor](https://digilent.com/shop/pmod-als-ambient-light-sensor/?srsltid=AfmBOoo6QBPfXvpRb76jZOooYKeqVoDgKQbbQaCbR2CjaA0lwguNXfQ5) (ALS).
The main parts of this project is the SPI controller, the UART controller, and the clock domain crossing (CDC) FIFO interlink. Although this project doesn't need CDC logic since both can be implemented with integer clock dividers, I wanted to learn about it and test it so they use differing clocks.

# Design

## Controllers

The controllers are essentially a simple busy/not busy FSM wrapped on top of a shift register that reads/writes the data.

## AFIFO

This is designed based on [this blog](https://zipcpu.com/blog/2018/07/06/afifo.html).

# How to Run

## Building for the FPGA

1. Clone this repository
2. Open repository in Xillinx Vivado and import all files
3. Build and Run with default settings

## Reading/Graphing output data

These steps are assuming a usb-serial interface on linux.

1. Install minicom and required python packages
2. Run the below to read the raw data

```sh
sudo minicom -b 115200 -D /dev/ttyUSB0 -c on

```

3. Run python

```sh
python live_graph.py
```

# Example Output

![](docs/adc_data.png?raw=true)
