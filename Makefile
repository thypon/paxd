CC = clang
CFLAGS := -std=c11 -D_FILE_OFFSET_BITS=64 -D_GNU_SOURCE \
	  $(shell pkg-config --cflags glib-2.0) \
	  -O2 -flto -fuse-ld=gold $(CFLAGS)
LDFLAGS := -O2 -flto -fuse-ld=gold -Wl,--as-needed,--gc-sections $(LDFLAGS)
LDLIBS := $(shell pkg-config --libs glib-2.0)

ifeq ($(CC), clang)
	CFLAGS += -Weverything -Wno-cast-align -Wno-disabled-macro-expansion -Wno-documentation \
		  -Wno-padded
else
	CFLAGS += -Wall -Wextra
endif

all: paxd
paxd: paxd.o flags.o
flags: flags.c flags.h

clean:
	rm -f paxd paxd.o flags.o

install: paxd paxd.conf
	install -Dm755 paxd $(DESTDIR)/usr/bin/paxd
	install -Dm600 paxd.conf $(DESTDIR)/etc/paxd.conf
	install -Dm644 paxd.service $(DESTDIR)/usr/lib/systemd/system/paxd.service
	install -Dm644 user.service $(DESTDIR)/usr/lib/systemd/user/paxd.service
	mkdir -p $(DESTDIR)/usr/lib/systemd/system/sysinit.target.wants
	ln -t $(DESTDIR)/usr/lib/systemd/system/sysinit.target.wants -sf ../paxd.service

.PHONY: all clean install
