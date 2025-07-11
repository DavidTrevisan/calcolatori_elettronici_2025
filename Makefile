# Makefile for building the final report

# Variables
DOC_GENERATOR = doc/bin/generateDoc
AUTHOR_NAME = David Trevisan
DOC_TITLE = CE-Report Progettuale
DATE = $(shell date -u +%Y-%m-%d)
GIT_SHA = $(shell git rev-parse --short=7 HEAD)
OUTPUT_FILE = $(shell echo "$(DOC_TITLE)-$(AUTHOR_NAME)-$(DATE)-$(GIT_SHA).pdf" | tr ' ' '_')

BUILD_DIR = doc/build

# Default target
all: pdf

# Target to generate the PDF
pdf:
	@echo "Generating PDF..."
	$(DOC_GENERATOR) -o $(OUTPUT_FILE)

# Target to clean up the build directory
clean:
	@echo "Cleaning up build directory..."
	@sudo rm -rf $(BUILD_DIR)
	@echo "Build directory removed."

# Phony targets
.PHONY: all pdf clean
