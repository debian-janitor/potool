#
# potool is a program aiding editing of po files
# Copyright (C) 1999-2002 Zbigniew Chyla
# Copyright (C) 2000-2019 Marcin Owsiany
#
# see LICENSE for licensing info
#

VER = 0.19

DESTDIR = /usr/local
BINDIR = $(DESTDIR)/bin
INSTALL = install
BININSTALL = $(INSTALL) -s
GTAR = tar
PKG_CONFIG ?= pkg-config

GLIB_LIB = $(shell $(PKG_CONFIG) --libs glib-2.0)
GLIB_INCLUDE = $(shell $(PKG_CONFIG) --cflags glib-2.0)
CPPFLAGS += $(GLIB_INCLUDE)
CFLAGS += -g -Wall -Werror
LDLIBS += $(GLIB_LIB)

THINGS  = potool po.tab lex.po
OBJS    = $(addsuffix .o, $(THINGS))
SOURCES = $(addsuffix .c, $(THINGS))

potool: $(OBJS)

po.tab.o lex.po.c lex.po.o: po-gram.h common.h

lex.po.c: po-gram.lex
	flex -Ppo $<
#	flex --debug -Ppo $<

po.tab.c: po-gram.y
	bison -ppo -bpo -d $<

install: potool
	$(INSTALL) -d $(BINDIR)
	$(BININSTALL) potool $(BINDIR)
	$(INSTALL) scripts/poedit $(BINDIR)
	$(INSTALL) scripts/postats $(BINDIR)
	$(INSTALL) scripts/poupdate $(BINDIR)
	$(INSTALL) change-po-charset $(BINDIR)

clean:
	rm -f $(OBJS) *~ lex.po.c po.tab.[ch] potool scripts/*~

dist: clean
	cd ..; \
	 rm -f potool-$(VER).tar{,.gz} potool-$(VER); \
	 ln -s potool potool-$(VER); \
	 $(GTAR) --exclude='*/.git*' --owner=root --group=root -hcf potool-$(VER).tar potool-$(VER) && \
	 gzip -9 potool-$(VER).tar

check: potool
	cd tests && bash test
# make clean check G_SLICE=always-malloc WRAPPER='valgrind --leak-check=full --show-reachable=yes --error-exitcode=1' CC=colorgcc CFLAGS="-O0 -Wall -Werror"
