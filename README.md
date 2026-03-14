# SPI To UART

Code for a FPGA to read a SPI sensor and output the message in UART. In this case, a Basys 3 with an SPI ambient light sensor.
The main parts of this project is the SPI controller, the UART controller, and the clock domain crossing (CDC) FIFO interlink.
