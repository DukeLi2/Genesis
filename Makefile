# ================= 项目配置 =================
PROJECT_NAME = Genesis
BUILD_DIR = build
LD_SCRIPT = Genesis.ld
.DEFAULT_GOAL := all

#源文件目录
SRC_DIR = \
	core \
	src

# 头文件搜索目录
INC_DIR = \
	src/led/inc

# ================= 工具链配置 =================
TOOLPREFIX := arm-none-eabi-
CC := $(TOOLPREFIX)gcc
AS := $(TOOLPREFIX)as
LD := $(TOOLPREFIX)ld
OBJCOPY := $(TOOLPREFIX)objcopy
OBJDUMP := $(TOOLPREFIX)objdump
NM := $(TOOLPREFIX)nm

# ================= 编译与链接选项 =================
CFLAGS += -Wall -Wextra -O2 -g
CFLAGS += -mcpu=cortex-m7 -mthumb -specs=nosys.specs

# 生成map文件
LDFLAGS += -Wl,-Map=$(BUILD_DIR)/bin/$(PROJECT_NAME).map
LDFLAGS += -T $(LD_SCRIPT)


# 自动生成头文件依赖关系
CFLAGS += -MMD -MP
# 头文件搜索编译选项
CPPFLAGS += $(addprefix -I,$(INC_DIR))

# ================= 文件收集 =================
# 递归搜索目录中的文件
rwildcard = $(foreach dir,$(wildcard $(1)*/),$(call rwildcard,$(dir),$(2))) $(wildcard $(1)$(2))
# 源文件收集
C_SRCS := $(foreach dir,$(SRC_DIR),$(call rwildcard,$(dir)/,*.c))
ASM_SRCS := $(foreach dir,$(SRC_DIR),$(call rwildcard,$(dir)/,*.s))

# obj文件收集进build/obj目录
OBJ_DIR := $(BUILD_DIR)/obj
C_OBJS := $(patsubst %.c,$(OBJ_DIR)/%.o,$(C_SRCS))
ASM_OBJS := $(patsubst %.s,$(OBJ_DIR)/%.o,$(ASM_SRCS))

# 目标文件与依赖文件收集
OBJS := $(C_OBJS) $(ASM_OBJS)
DEPS := $(OBJS:.o=.d)

# 读取编译器生成的头文件依赖
-include $(DEPS)

# ================= 构建规则 =================
$(OBJ_DIR)/%.o: %.c
	@mkdir -p $(dir $@)
	$(CC) $(CFLAGS) $(CPPFLAGS) -c $< -o $@

$(OBJ_DIR)/%.o: %.s
	@mkdir -p $(dir $@)
	$(CC) $(CFLAGS) $(CPPFLAGS) -c $< -o $@

#================= 构建目标 =================
TARGET := $(BUILD_DIR)/bin/$(PROJECT_NAME).elf

$(TARGET): $(OBJS)
	@mkdir -p $(dir $@)
	$(CC) $(CFLAGS) $(LDFLAGS) $^ -o $@
#	$(OBJDUMP) -d -S $(TARGET) > $(BUILD_DIR)/bin/$(PROJECT_NAME).asm
	$(NM) -n $(TARGET) > $(BUILD_DIR)/bin/$(PROJECT_NAME).sym

BIN_FILE := $(BUILD_DIR)/bin/$(PROJECT_NAME).bin

$(BIN_FILE): $(TARGET)
	@mkdir -p $(dir $@)
	$(OBJCOPY) -O binary $< $@

HEX_FILE := $(BUILD_DIR)/bin/$(PROJECT_NAME).hex

$(HEX_FILE): $(TARGET)
	@mkdir -p $(dir $@)
	$(OBJCOPY) -O ihex $< $@

all: $(TARGET) $(BIN_FILE) $(HEX_FILE)

# 删除所有生成物
.PHONY: clean
clean:
	@rm -rf $(BUILD_DIR)