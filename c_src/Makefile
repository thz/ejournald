PRIVDIR := ../priv
CC ?= gcc
RM ?= rm
CFLAGS ?= -O2

override CFLAGS += -std=gnu99  -Wall -fpic -I. $(shell erl -noinput -eval 'io:format("-I~s/erts-~s/include", [code:root_dir(), erlang:system_info(version)]), halt(0).') $(shell pkg-config --cflags libsystemd-journal)

override LDFLAGS += -shared -fpic $(shell pkg-config --libs libsystemd-journal)

all : $(PRIVDIR)/journald_api.so

$(PRIVDIR)/journald_api.so : journald_api.o
	mkdir -p $(PRIVDIR)
	$(CC) $^ $(LDFLAGS) -o $@

clean:
	$(RM) -f $(PRIVDIR)/journald_api.so journald_api.o
