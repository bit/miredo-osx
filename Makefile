

TARNAME=miredo-osx-v1.2.6-beta3
IDENTIFIER=com.github.bit.miredo-osx

##### Path Variables
PREFIX=/usr/local
SYSCONF=/usr/local/etc
LOCALSTATE=/var
MISC_DIR=$(shell pwd)/misc
BUILD_DIR=$(shell pwd)/build
UTIL_DIR=$(shell pwd)/util
OUT_DIR=$(BUILD_DIR)/out
TMP_DIR=/tmp
RESOURCES_DIR=$(shell pwd)/Resources


## miredo
MIREDO_SRC_DIR=$(shell pwd)/miredo
MIREDO_BUILD_X86_DIR=$(BUILD_DIR)/miredo_build_x86
MIREDO_BUILD_X86_64_DIR=$(BUILD_DIR)/miredo_build_x86_64
MIREDO_OUT_X86_DIR=$(BUILD_DIR)/miredo_out_x86
MIREDO_OUT_X86_64_DIR=$(BUILD_DIR)/miredo_out_x86_64
MIREDO_CONFIG_FLAGS+="--enable-miredo-user=nobody"
MIREDO_CONFIG_FLAGS+="--without-libiconv-prefix"
MIREDO_CONFIG_FLAGS+="--without-gettext"
MIREDO_CONFIG_FLAGS+="--without-libintl-prefix"
MIREDO_CONFIG_FLAGS+="--localstatedir=$(LOCALSTATE)"
MIREDO_CONFIG_FLAGS+="--sysconfdir=$(SYSCONF)"
MIREDO_CONFIG_FLAGS+="--disable-shared"
MIREDO_CONFIG_FLAGS+="--enable-static"
MIREDO_CONFIG_FLAGS+="--disable-sample-conf"
MIREDO_CONFIG_FLAGS+="--prefix=$(PREFIX)"
MIREDO_CONFIG_FLAGS+="gt_cv_func_gnugettext1_libintl=no"
MIREDO_CONFIG_FLAGS+="ac_cv_header_libintl_h=no"

## libJudy
JUDY_SRC_DIR=$(shell pwd)/libjudy
JUDY_BUILD_X86_DIR=$(BUILD_DIR)/judy_build_x86
JUDY_BUILD_X86_64_DIR=$(BUILD_DIR)/judy_build_x86_64
JUDY_OUT_X86_DIR=$(BUILD_DIR)/judy_out_x86
JUDY_OUT_X86_64_DIR=$(BUILD_DIR)/judy_out_x86_64
JUDY_CONFIG_FLAGS+="--disable-shared"
JUDY_CONFIG_FLAGS+="--enable-static"

## Uninstaller
UNINST_SCRIPT_DIR=/Applications/Utilities
UNINST_SCRIPT=$(UNINST_SCRIPT_DIR)/uninstall-miredo.command

##### Tool Variables
RMDIR=rm -fr
MKDIR=mkdir
CP=cp
MAKE=make
TEST=test
MAKE_UNIVERSAL=$(shell pwd)/util/make_universal
RMKDIR=$(shell pwd)/util/rmkdir
XCODEBUILD=/usr/bin/xcodebuild


##### Targets


.PHONY: all miredo package clean libjudy uninst-script default

default: package

all: miredo uninst-script package

uninst-script: $(OUT_DIR)$(UNINST_SCRIPT)

$(OUT_DIR)$(UNINST_SCRIPT): miredo
	$(RMKDIR) $(OUT_DIR)$(UNINST_SCRIPT_DIR)
	echo "#!/bin/sh" > $(OUT_DIR)$(UNINST_SCRIPT)
	echo "cd /" >> $(OUT_DIR)$(UNINST_SCRIPT)
	echo "sudo launchctl unload /Library/LaunchDaemons/miredo.plist" >> $(OUT_DIR)$(UNINST_SCRIPT)
	echo "sudo killall -9 miredo" >> $(OUT_DIR)$(UNINST_SCRIPT)
	for FILE in `cd $(OUT_DIR) ; find . ` ; do { \
		( cd $(OUT_DIR) && [ -d $$FILE ] ) && continue ; \
		echo "sudo rm $$FILE" | grep -v .svn >> $(OUT_DIR)$(UNINST_SCRIPT) ; \
	} ; done ;
	echo "sudo rm -rf /Library/PreferencePanes/Miredo.prefPane" >> $(OUT_DIR)$(UNINST_SCRIPT)
	echo "sudo rm $(UNINST_SCRIPT)" >> $(OUT_DIR)$(UNINST_SCRIPT)
	chmod +x $(OUT_DIR)$(UNINST_SCRIPT)

miredo-clean:
	$(RM) -r $(MIREDO_BUILD_X86_DIR) $(MIREDO_BUILD_X86_64_DIR)  $(MIREDO_OUT_X86_DIR)  $(MIREDO_OUT_X86_64_DIR)

$(MIREDO_SRC_DIR)/include/gettext.h:
	$(CP) $(MISC_DIR)/gettext.h $(MIREDO_SRC_DIR)/include/gettext.h

$(MIREDO_BUILD_X86_DIR)/config.status: $(MIREDO_SRC_DIR)/include/gettext.h $(JUDY_OUT_X86_DIR)/lib/libJudy.a
	-$(RMKDIR) $(BUILD_DIR)
	-$(RMKDIR) $(MIREDO_BUILD_X86_DIR)
	-$(RMKDIR) $(MIREDO_OUT_X86_DIR)
	cd $(MIREDO_BUILD_X86_DIR) && $(MIREDO_SRC_DIR)/configure \
	    $(MIREDO_CONFIG_FLAGS) CFLAGS="-arch i386 -O2 -I$(JUDY_OUT_X86_DIR)/include -mmacosx-version-min=10.5" \
        LDFLAGS=-mmacosx-version-min=10.5 \
	    --with-Judy=$(JUDY_OUT_X86_DIR) LDFLAGS=-L$(JUDY_OUT_X86_DIR)/lib

$(MIREDO_BUILD_X86_64_DIR)/config.status: $(MIREDO_SRC_DIR)/include/gettext.h $(JUDY_OUT_X86_64_DIR)/lib/libJudy.a
	-$(RMKDIR) $(BUILD_DIR)
	-$(RMKDIR) $(MIREDO_BUILD_X86_64_DIR)
	-$(RMKDIR) $(MIREDO_OUT_X86_64_DIR)
	cd $(MIREDO_BUILD_X86_64_DIR) && $(MIREDO_SRC_DIR)/configure \
	    $(MIREDO_CONFIG_FLAGS) CFLAGS="-arch x86_64 -O2 -I$(JUDY_OUT_X86_64_DIR)/include -mmacosx-version-min=10.5" \
	    LDFLAGS=-mmacosx-version-min=10.5 \
	    --with-Judy=$(JUDY_OUT_X86_64_DIR) LDFLAGS=-L$(JUDY_OUT_X86_64_DIR)/lib

$(MIREDO_OUT_X86_DIR)$(PREFIX)/sbin/miredo: $(MIREDO_BUILD_X86_DIR)/config.status
	$(MAKE) -C $(MIREDO_BUILD_X86_DIR)
	$(MAKE) -C $(MIREDO_BUILD_X86_DIR) install DESTDIR=$(MIREDO_OUT_X86_DIR)

$(MIREDO_OUT_X86_64_DIR)$(PREFIX)/sbin/miredo: $(MIREDO_BUILD_X86_64_DIR)/config.status
	$(MAKE) -C $(MIREDO_BUILD_X86_64_DIR)
	$(MAKE) -C $(MIREDO_BUILD_X86_64_DIR) install DESTDIR=$(MIREDO_OUT_X86_64_DIR)

$(OUT_DIR)$(PREFIX)/sbin/miredo: $(MIREDO_SRC_DIR)/configure $(MIREDO_OUT_X86_DIR)$(PREFIX)/sbin/miredo $(MIREDO_OUT_X86_64_DIR)$(PREFIX)/sbin/miredo
	$(MAKE_UNIVERSAL) $(OUT_DIR) $(MIREDO_OUT_X86_DIR) $(MIREDO_OUT_X86_64_DIR)
	rm -rf \
	    $(OUT_DIR)/usr/lib \
	    $(OUT_DIR)/usr/include \
	    $(OUT_DIR)/usr/bin \
	    $(OUT_DIR)/var \
	    $(OUT_DIR)/usr/sbin/miredo-server \
	    $(OUT_DIR)/usr/share

miredo: $(OUT_DIR)$(PREFIX)/sbin/miredo $(OUT_DIR)$(SYSCONF)/miredo.conf.sample $(OUT_DIR)/Library/LaunchDaemons/miredo.plist

$(OUT_DIR)$(SYSCONF)/miredo.conf.sample: $(MISC_DIR)/miredo.conf
	-$(RMKDIR) $(OUT_DIR)$(SYSCONF)
	$(CP) $(MISC_DIR)/miredo.conf $(OUT_DIR)$(SYSCONF)/miredo.conf.sample

$(OUT_DIR)/Library/LaunchDaemons/miredo.plist: $(MISC_DIR)/miredo.plist
	-$(RMKDIR) $(OUT_DIR)/Library/LaunchDaemons
	$(CP) $(MISC_DIR)/miredo.plist $(OUT_DIR)/Library/LaunchDaemons/miredo.plist

$(JUDY_SRC_DIR)/configure: $(JUDY_SRC_DIR)/configure.ac
	cd $(JUDY_SRC_DIR) && ./bootstrap
	# Libjudy is a little screwed up, so we need to do a build pass on the main directory first
	cd $(JUDY_SRC_DIR) && ./configure
	make -C $(JUDY_SRC_DIR)
	make -C $(JUDY_SRC_DIR) distclean

$(MIREDO_SRC_DIR)/configure:
	cd $(MIREDO_SRC_DIR) && PATH=$(PATH):/usr/local/Cellar/gettext/0.18.3.2/bin ./autogen.sh

Judy-1.0.5.tar.gz:
	curl http://dfn.dl.sourceforge.net/project/judy/judy/Judy-1.0.5/Judy-1.0.5.tar.gz > Judy-1.0.5.tar.gz

libjudy: $(JUDY_OUT_X86_DIR)/lib/libJudy.a $(JUDY_OUT_X86_64_DIR)/lib/libJudy.a

libjudy-x86-conf: $(JUDY_BUILD_X86_DIR)/config.status

libjudy-x86-build: $(JUDY_BUILD_X86_DIR)/config.status
	$(MAKE) -C $(JUDY_BUILD_X86_DIR)

$(JUDY_BUILD_X86_DIR)/config.status: Judy-1.0.5.tar.gz
	-$(RMKDIR) $(BUILD_DIR)
	test -e $(JUDY_BUILD_X86_DIR) || (tar xzf Judy-1.0.5.tar.gz && mv judy-1.0.5 $(JUDY_BUILD_X86_DIR))
	-$(RMKDIR) $(JUDY_OUT_X86_DIR)
	cd $(JUDY_BUILD_X86_DIR) && ./configure $(JUDY_CONFIG_FLAGS) \
	    CFLAGS='-arch i386 -O2 -mmacosx-version-min=10.5' --prefix=$(JUDY_OUT_X86_DIR)

$(JUDY_OUT_X86_DIR)/lib/libJudy.a: $(JUDY_BUILD_X86_DIR)/config.status
	$(MAKE) -C $(JUDY_BUILD_X86_DIR) install

libjudy-x86_64-conf: $(JUDY_BUILD_X86_64_DIR)/config.status

libjudy-x86_64-build: $(JUDY_BUILD_X86_64_DIR)/config.status
	$(MAKE) -C $(JUDY_BUILD_X86_64_DIR)

$(JUDY_BUILD_X86_64_DIR)/config.status: Judy-1.0.5.tar.gz
	-$(RMKDIR) $(BUILD_DIR)
	test -e $(JUDY_BUILD_X86_64_DIR) || (tar xzf Judy-1.0.5.tar.gz && mv judy-1.0.5 $(JUDY_BUILD_X86_64_DIR))
	-$(RMKDIR) $(JUDY_OUT_X86_64_DIR)
	cd $(JUDY_BUILD_X86_64_DIR) && ./configure $(JUDY_CONFIG_FLAGS) \
	    CFLAGS='-arch x86_64 -O2 -mmacosx-version-min=10.5' --prefix=$(JUDY_OUT_X86_64_DIR)

$(JUDY_OUT_X86_64_DIR)/lib/libJudy.a: $(JUDY_BUILD_X86_64_DIR)/config.status
	$(MAKE) -C $(JUDY_BUILD_X86_64_DIR) install


$(TARNAME).pkg: miredo uninst-script
	pkgbuild --identifier $(IDENTIFIER) --scripts $(RESOURCES_DIR) --root $(OUT_DIR) $(TARNAME).pkg

package: $(TARNAME).pkg
	
clean:
	$(RMDIR) $(BUILD_DIR)
	$(RMDIR) $(TARNAME).pkg
