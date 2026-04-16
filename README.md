# Linux on STM32F429-Discovery
This is a patchset optimized for space constraints on STM32F429-Discovery.

Expanding on my previous milestone of [running Linux on the 1MB RAM STM32H750](https://github.com/rota1001/stm32h7-linux), this project utilizes the STM32F429's external SDRAM to explore a broader Linux software stack on microcontrollers.

## Dependencies
```shell
$ sudo apt -y install unzip bc build-essential
```

## Usage
```shell
$ git clone https://github.com/rota1001/stm32f429-linux.git
$ cd stm32f429-linux
$ ./build.sh
```
