#
# Author: Fengling <Fengling.Qin@gmail.com>
#
# This is free and unencumbered software released into the public domain.
# For details see the UNLICENSE file at the root of the source tree.
#

CROSS ?= /opt/riscv32imc/bin/riscv32-unknown-elf-

CC    := $(CROSS)gcc
LD    := $(CROSS)gcc
SIZE  := $(CROSS)size
AR    := $(CROSS)ar

# ----- Quiet code ----------------------------------------------------------
SHELL=/bin/bash
CPP := $(CPP)   # make sure changing CC won't affect CPP

CC_normal	:= $(CC)
AR_normal	:= $(AR)
LD_normal	:= $(LD)
DEPEND_normal	:= $(CPP) $(CFLAGS) -D__OPTIMIZE__ -MM -MG
RANLIB_normal	:= ranlib

CC_quiet	= @echo "  CC       " $@ && $(CC_normal)
AR_quiet	= @echo "  AR       " $@ && $(AR_normal)
LD_quiet	= @echo "  LD       " $@ && $(LD_normal)
DEPEND_quiet	= @$(DEPEND_normal)
RANLIB_quiet	= @$(RANLIB_normal)

ifeq ($(V),1)
    CC		= $(CC_normal)
    AR		= $(AR_normal)
    LD		= $(LD_normal)
    DEPEND	= $(DEPEND_normal)
    RANLIB	= $(RANLIB_normal)
else
    CC		= $(CC_quiet)
    AR		= $(AR_quiet)
    LD		= $(LD_quiet)
    DEPEND	= $(DEPEND_quiet)
    RANLIB	= $(RANLIB_quiet)
endif

CPU_CONFIG = -march=rv32imc
CPPFLAGS   += -std=gnu99 -O0 -ffunction-sections -ffreestanding \
		-Wall -Werror \
		-Wstrict-prototypes -Wmissing-prototypes \
		-Wold-style-declaration -Wold-style-definition \
		$(CPU_CONFIG) $(INCLUDES)
