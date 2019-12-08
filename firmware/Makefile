#
# Author: Fengling <Fengling.Qin@gmail.com>
#
# This is free and unencumbered software released into the public domain.
# For details see the UNLICENSE file at the root of the source tree.
#

BIN_DIR:=$(shell date +%Y-%m-%d)
GIT_VERSION:=$(shell git rev-parse HEAD | cut -c 1-7)
GIT_STATUS:=$(shell ([ -z "`git status -s -uno`" ] && echo 0) || echo +)
PROJ_NAME	= MMX

CFLAGS += -DMM_VERSION='"CN1912-$(GIT_VERSION)$(GIT_STATUS)"'

-include config.mk
# ----- Customer ----------------------------------------------------------
INCLUDES   = -I. -Isdk -Iminilibc
LDFLAGS    += -nostartfiles -nodefaultlibs -nostdlib -Wl,--gc-sections -Wl,-T,linker.ld -Wl,-Map=$(PROJ_NAME).map
LDLIBS     += -Bminilibc -lminilibc -lgcc

SSRCS      = sdk/start.S
CSRCS      = main.c timer.c gpio.c
OBJS       := $(addsuffix .o,$(basename $(CSRCS) $(SSRCS)))

vivado_dir  ?= /opt/Xilinx/Vivado/2019.1/
xil_env ?= . $(vivado_dir)/settings$(shell getconf LONG_BIT).sh &>/dev/null

ifeq ($(DEBUG),1)
	CFLAGS += -DDEBUG
endif

.PHONY: all clean

# C rules
all: $(PROJ_NAME).hex
	mkdir -p bin/${BIN_DIR}
	cp $^ bin/${BIN_DIR}
	cd bin/${BIN_DIR} && md5sum -b * > md5sums

$(PROJ_NAME).hex: $(PROJ_NAME).bin makehex.py
	python3 makehex.py $< 16384 > $@

$(PROJ_NAME).bin: $(PROJ_NAME).elf
	$(CROSS)objcopy -O binary $< $@

$(PROJ_NAME).elf: $(OBJS) minilibc/libminilibc.a
	$(LD) $(LDFLAGS) $(OBJS) -o $@ $(LDLIBS)
	$(CROSS)objdump -D $@ > $(PROJ_NAME).objdump
	$(SIZE) $@

minilibc/libminilibc.a:
	make -C `dirname $@`

%.o: %.c
	$(CC) $(CPPFLAGS) $(CFLAGS) -o $@ -c $<
	$(MKDEP)

# Clean rules
clean:
	rm -f $(OBJS) $(OBJS:.o=.d) $(PROJ_NAME).objdump $(PROJ_NAME).map $(PROJ_NAME).elf $(PROJ_NAME).bin $(PROJ_NAME).hex
	make -C minilibc clean

# ----- Dependencies ----------------------------------------------------------
MKDEP =									\
	$(DEPEND) $< |							\
	  sed 								\
	    -e 's|^$(basename $(notdir $<)).o:|$@:|'			\
	    -e '/^\(.*:\)\? */{p;s///;s/ *\\\?$$/ /;s/  */:\n/g;H;}'	\
	    -e '$${g;p;}'						\
	    -e d >$(basename $@).d;					\
	  [ "$${PIPESTATUS[*]}" = "0 0" ] ||				\
	  { rm -f $(basename $@).d; exit 1; }

-include $(OBJS:.o=.d)
