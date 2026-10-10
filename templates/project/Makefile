# @PROJECT@ - KallistiOS + sh4zam project
# Requires the KOS environment: . /opt/toolchains/dc/kos/environ.sh

TARGET   = @PROJECT@.elf
CDI      = @PROJECT@.cdi
SRC_LANG = c

OBJS = $(patsubst %.c,%.o,$(wildcard src/*.c)) \
       $(patsubst %.cpp,%.o,$(wildcard src/*.cpp))

# sh4zam's C++ API needs C++20 or newer.
export KOS_CPPFLAGS := $(KOS_CPPFLAGS) -std=gnu++20

# kos-ports installs into $(KOS_PORTS)/lib and /include, which kos-cc already
# searches, so linking a port is just -l<name>.
LIBS = -lsh4zam

ifeq ($(SRC_LANG),cpp)
  LINK = kos-c++
else
  LINK = kos-cc
endif

all: rm-elf $(TARGET)

include $(KOS_BASE)/Makefile.rules

$(TARGET): $(OBJS)
	$(LINK) -o $@ $(OBJS) $(LIBS)

clean: rm-elf
	-rm -f $(OBJS) $(CDI)

rm-elf:
	-rm -f $(TARGET)

# Send to a Dreamcast running dcload (uses KOS_LOADER from environ.sh)
run: $(TARGET)
	$(KOS_LOADER) $(TARGET)

# Self-boot disc image for CD-R / ODE / emulator
cdi: $(TARGET)
	mkdcdisc -e $(TARGET) -o $(CDI) -n "@PROJECT@"

# Windows Flycast from WSL. new-project.sh fills in the skill folder; override
# with DC_KOS_SETUP=... if the skill lives elsewhere on this machine.
DC_KOS_SETUP ?= @SKILL_DIR@
flycast: $(TARGET)
	bash $(DC_KOS_SETUP)/scripts/run-flycast.sh $(TARGET)

.PHONY: all clean rm-elf run cdi flycast
