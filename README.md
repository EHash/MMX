## MMX - Miner Manager with Extension

Miner Manager is a stratum task generator firmware that fit FPGA and ASIC miners.

### Main objectives

* It is using stratum protocol
* It generate the tasks (block headers) inside FPGA. all Double-SHA256 was done by FPGA, far more faster than CPU
* Test the nonce inside the FPGA. only report the >= DIFF tasks back to the host (CGMiner)
* It fits any kinds of stratum mining ASIC
* It has a RISC-V 32 bit CPU inside (PicoRV32)

### Directory structure

* `firmware`: C codes running in PicoRV32 soft processor
* `platform`: platform hardware library
* `testbench`: hardware testbench
* `top`: hardware top module & constrain
* `modules`: 3rd party modules

### Clone the code

```bash
  $ git clone --recursive https://github.com/EHash/MMX.git
```

### Tools being used

1. [Vivado](https://www.xilinx.com/support/download/index.html/content/xilinx/en/downloadNav/vivado-design-tools/2019-2.html): install vivado and source the setttings, we use 2019.2 as default
2. [FuseSoC](https://github.com/EHash/fusesoc): for IP-packaging and project generation
3. [Cheby](https://github.com/EHash/cheby): for register-map generation
4. [vhd2vl](https://github.com/ldoolitt/vhd2vl): for converting from VHDL to Verilog code
2. RV32IMC toolchain: compile with IMC extension, we choose /opt/riscv32imc as default install directory.

### How to build & sim?

Before the build & sim, we need to setup the environment first.

```bash
  $ fusesoc init
  $ fusesoc library add --global mmx .
```

* Build with Vivado

```bash
   $ make
```

* Load the bitstream with Vivado

```bash
   $ make load      # Load the bitstream to FPGA
```

* Sim with icarus

```bash
   $ make sim
   $ make view
```

### Hardware support

* ZedBoard

### Discussion

* Telegram: https://t.me/EHashPublic

### TODO

* Add toolchain compile support
* Add uart debug support
* Add btc core support

### License

This is free and unencumbered public domain software. For more information,
see http://unlicense.org/ or the accompanying UNLICENSE file.

Some files may have their own license disclaim by the author.
