BUILD_DIR?=./build
SRC_DIRS?=./src/
SIMBLEE_DIR?=/home/$(USER)/.arduino15/packages/Simblee/hardware/Simblee/1.1.4
NRF_SDK_DIR?=/opt/nRF5_SDK_12.3.0

INCDIRS=-I./include \
		-I$(SIMBLEE_DIR) \
		-I$(NRF_SDK_DIR)/components/device \
		-I$(NRF_SDK_DIR)/components/drivers_nrf/delay \
		-I$(NRF_SDK_DIR)/components/drivers_nrf/hal \
		-I$(NRF_SDK_DIR)/components/drivers_nrf/nrf_soc_nosd \
		-I$(NRF_SDK_DIR)/components/drivers_nrf/uart \
		-I$(NRF_SDK_DIR)/components/libraries/uart \
		-I$(NRF_SDK_DIR)/components/libraries/util \
		-I$(NRF_SDK_DIR)/components/toolchain \
		-I$(NRF_SDK_DIR)/components/toolchain/cmsis/include \
		-I$(NRF_SDK_DIR)/components/libraries/log \
		-I$(NRF_SDK_DIR)/components/libraries/log/src \
		-I$(NRF_SDK_DIR)/components/drivers_nrf/common \
		-I$(SIMBLEE_DIR)/system/Simblee/include

SRCS := src/main.c \
   $(NRF_SDK_DIR)/components/libraries/uart/app_uart.c \
   $(NRF_SDK_DIR)/components/libraries/util/app_error.c \
   $(NRF_SDK_DIR)/components/libraries/util/app_error_weak.c \
   $(NRF_SDK_DIR)/components/drivers_nrf/common/nrf_drv_common.c \
   $(NRF_SDK_DIR)/components/drivers_nrf/uart/nrf_drv_uart.c \
   $(SIMBLEE_DIR)/system/Simblee/source/startup_nrf51822.c \
   src/syscalls.c 

OBJS:=$(patsubst %,$(BUILD_DIR)/%.o,$(notdir $(SRCS)))

CC=arm-none-eabi-gcc
CFLAGS=-c
CFLAGS+=-g
CFLAGS+=-Os
CFLAGS+=-w
CFLAGS+=-std=gnu11
CFLAGS+=-ffunction-sections
CFLAGS+=-fdata-sections
CFLAGS+=-fno-rtti
CFLAGS+=-fno-exceptions
CFLAGS+=-fno-builtin
CFLAGS+=-MMD
CFLAGS+=-mcpu=cortex-m0
CFLAGS+=-DF_CPU=16000000
CFLAGS+=-mthumb
CFLAGS+=-DNRF51
CFLAGS+=-DUART_PRESENT
CFLAGS+=-DGPIO_COUNT=1
CFLAGS+=-DP0_PIN_NUM=30

CPP=arm-none-eabi-g++
CPPFLAGS=-c
CPPFLAGS+=-g
CPPFLAGS+=-Os
CPPFLAGS+=-w
CPPFLAGS+=-std=gnu++11
CPPFLAGS+=-ffunction-sections
CPPFLAGS+=-fdata-sections
CPPFLAGS+=-fno-rtti
CPPFLAGS+=-fno-exceptions
CPPFLAGS+=-fno-builtin
CPPFLAGS+=-MMD
CPPFLAGS+=-mcpu=cortex-m0
CPPFLAGS+=-DF_CPU=16000000
CPPFLAGS+=-mthumb
CPPFLAGS+=-DNRF51
CPPFLAGS+=-DUART_PRESENT

LDFLAGS=-Wl,--gc-sections
#LDFLAGS+=--specs=nosys.specs
LDFLAGS+=--specs=nano.specs
LDFLAGS+=-mcpu=cortex-m0
LDFLAGS+=-mthumb
LDFLAGS+=-D__Simblee__
LDFLAGS+=-T$(SIMBLEE_DIR)/variants/Simblee/linker_scripts/gcc/Simblee.ld
LDFLAGS+=-Wl,--cref
LDFLAGS+=-Wl,--warn-common
LDFLAGS+=-Wl,--warn-section-align
LDFLAGS+=-Wl,--start-group
LDFLAGS+=$(SIMBLEE_DIR)/variants/Simblee/libSimbleeSystem.a

AR=arm-none-eabi-ar
OBJCOPY=arm-none-eabi-objcopy
RFDLOADER=$(SIMBLEE_DIR)/RFDLoader_linux

print-%  : ; @echo $* = $($*)
print-file-%.c.o  : ; @echo $* = $(filter %$*.c,$(SRCS))
print-file-%.cpp.o  : ; @echo $* = $(filter %$*.cpp,$(SRCS))

.PHONY: all clean upload

all: directories $(BUILD_DIR)/firmware.hex

$(BUILD_DIR)/%.c.o: $(filter %$*.c,$(SRCS))
	@echo $*
	$(CC) $(CFLAGS) $(INCDIRS) -o $@ $(filter %$*.c,$(SRCS))

$(BUILD_DIR)/%.cpp.o: $(filter %$*.cpp,$(SRCS))
	@echo $*
	$(CPP) $(CPPFLAGS) $(INCDIRS) -o $@ $(filter %$*.cpp,$(SRCS))

$(BUILD_DIR)/firmware.elf: $(OBJS)
	$(CPP) $(LDFLAGS) $(OBJS) -Wl,--end-group -Wl,-Map,$@.map -o $@

$(BUILD_DIR)/firmware.hex: $(BUILD_DIR)/firmware.elf
	$(OBJCOPY) -O ihex $< $@

upload: $(BUILD_DIR)/firmware.hex
	$(RFDLOADER) /dev/ttyUSB0 $<

directories: $(BUILD_DIR)

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

clean:
	rm -rf $(BUILD_DIR)
