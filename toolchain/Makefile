SHELL=/bin/bash
ifndef TOOLCHAINDIR
$(error TOOLCHAINDIR is undefined)
endif

ifndef TRIPLET
$(error TRIPLET is undefined)
endif
TOOLCHAINDIR := $(shell realpath $(TOOLCHAINDIR))

BUILD_TRIPLET=$(shell ./config.guess)
export PATH:=$(PATH):$(TOOLCHAINDIR)/bin

DIRS := $(subst ./,,$(shell find . -maxdepth 1 -mindepth 1 -type d))
TOOLS := $(DIRS)

all: build-all

.PHONY: $(addprefix do-build-,$(TOOLS))
.PHONY: $(addprefix clean-,$(DIRS))
.PHONY: $(addprefix cleansrc-,$(DIRS))
.PHONY: $(addprefix distclean-,$(DIRS))

cleansrc: $(addprefix cleansrc-,$(DIRS))
clean: $(addprefix clean-,$(DIRS))
distclean: $(addprefix distclean-,$(DIRS))

$(foreach dir,$(DIRS),$(eval include $(dir)/make.inc)$(eval include make.inc))

.PHONY: $(addprefix build-,$(TOOLS))
build-all: $(addprefix do-build-,$(TOOLS))

