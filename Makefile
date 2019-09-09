
PREFIX ?= /usr/local
BINDIR ?= $(PREFIX)/bin
CONFIG_FILE ?= ~/.ssh/xssh.json

.DEFAULT_GOAL := install

init:
	@cp -i config.example.json $(CONFIG_FILE)

install:
	@install -v -d "$(BINDIR)" && install -v -m 0755 xssh.sh "$(BINDIR)/xssh"

uninstall:
	@rm -i "$(BINDIR)/xssh"
	@rm -i $(CONFIG_FILE)

.PHONY: install uninstall init
