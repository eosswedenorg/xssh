
NAME ?= xssh
PREFIX ?= /usr/local
BINDIR ?= $(PREFIX)/bin
SHAREDIR = $(PREFIX)/share/$(NAME)
CONFIG_FILE ?= ~/.ssh/$(NAME).json

.DEFAULT_GOAL := install

install: install_bin install_share

install_bin: xssh.build.sh
	@install -v -d "$(BINDIR)" && install -v -m 0755 $^ "$(BINDIR)/xssh"

install_share: README.md LICENSE config.json
	install -v -d "$(SHAREDIR)" && install -v -m 0644 $^ "$(SHAREDIR)"

uninstall:
	@rm -i "$(BINDIR)/xssh"
	@rm -r "$(SHAREDIR)"

xssh.build.sh: xssh.sh
	cat $^ \
		| sed -E "s#^(DEFAULT_CONFIG=)(.*)#\1\"$(SHAREDIR)/config.json\"#" > $@

.PHONY: install install_bin install_share uninstall xssh.build.sh
