SHELL := /bin/sh
APPS_DIR ?= $(HOME)/Applications
APP_NAME := Toggle Headphones
SOURCE := $(APP_NAME).applescript
APP := $(APPS_DIR)/$(APP_NAME).app
COMPILED_SCRIPT := $(APP)/Contents/Resources/Scripts/main.scpt

# Make requires escaped spaces in targets and prerequisites, unlike shell args.
empty :=
space := $(empty) $(empty)
escape_spaces = $(subst $(space),\$(space),$(1))

.PHONY: all build verify test
.DELETE_ON_ERROR:

all: build

build: $(call escape_spaces,$(COMPILED_SCRIPT))

$(call escape_spaces,$(COMPILED_SCRIPT)): $(call escape_spaces,$(SOURCE)) Makefile
	mkdir -p "$(APPS_DIR)"
	osacompile -o "$(APP)" "$(SOURCE)"
	codesign --force --sign - "$(APP)"
	codesign --verify --verbose=2 "$(APP)"

verify: build
	codesign --verify --verbose=2 "$(APP)"

test: verify
	osascript "../tests/toggle-headphones.applescript" "$(COMPILED_SCRIPT)"
