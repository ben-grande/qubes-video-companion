# Copyright (C) 2021 Elliot Killick <elliotkillick@zohomail.eu>
# Licensed under the MIT License. See LICENSE file for details.

PKGNAME = qubes-video-companion

BINDIR ?= /usr/bin
DATADIR ?= /usr/share
SYSCONFDIR ?= /etc
QREXECSERVICEDIR ?= $(SYSCONFDIR)/qubes-rpc
QREXECPOLICYDIR ?= $(SYSCONFDIR)/qubes/policy.d
PYTHON ?= python3

INSTALL_DIR = install -d --
INSTALL_PROGRAM = install -D --
INSTALL_DATA = install -Dm 644 --

help:
	@echo "make build		Build components"
	@echo "make install-vm		Install all components necessary for VMs"
	@echo "make install-dom0	Install all components necessary for dom0"
	@echo "make install-both	Install components necessary for VMs and dom0"
	@echo "make install-policy	Install qrexec policies"
	@echo "make install-tests	Install integration tests"
	@echo "make install-license	Install license to $(DATADIR)/licenses/$(PKGNAME)"
	@echo "make clean		Clean build"

build:
	$(MAKE) -C doc manpages

install-v4l2loopback-script:
	$(INSTALL_PROGRAM) scripts/v4l2loopback/install.sh $(DESTDIR)$(DATADIR)/$(PKGNAME)/scripts/v4l2loopback
	$(INSTALL_DATA) scripts/v4l2loopback/author.asc $(DESTDIR)$(DATADIR)/$(PKGNAME)/scripts/v4l2loopback

install-vm: install-both
	$(INSTALL_DIR) $(DESTDIR)$(BINDIR)
	$(INSTALL_PROGRAM) receiver/$(PKGNAME) $(DESTDIR)$(BINDIR)
	$(INSTALL_DIR) $(DESTDIR)$(DATADIR)/$(PKGNAME)/receiver
	$(INSTALL_PROGRAM) receiver/setup.sh receiver/receiver.py receiver/destroy.sh receiver/common.sh $(DESTDIR)$(DATADIR)/$(PKGNAME)/receiver
	$(INSTALL_DIR) $(DESTDIR)$(SYSCONFDIR)/qubes/rpc-config
	echo 'wait-for-session=1' > $(DESTDIR)$(SYSCONFDIR)/qubes/rpc-config/qvc.Webcam
	echo 'wait-for-session=1' > $(DESTDIR)$(SYSCONFDIR)/qubes/rpc-config/qvc.ScreenShare
	$(INSTALL_DIR) $(DESTDIR)$(DATADIR)/$(PKGNAME)/scripts
	$(INSTALL_DATA) scripts/webcam.html $(DESTDIR)$(DATADIR)/$(PKGNAME)/scripts
	$(INSTALL_DATA) scripts/dkms-skip.conf $(DESTDIR)$(SYSCONFDIR)/dkms/v4l2loopback.conf
	$(INSTALL_DIR) $(DESTDIR)$(DATADIR)/$(PKGNAME)/scripts/v4l2loopback
	$(MAKE) -C doc install

install-dom0: install-both install-policy install-tests

install-both:
	$(INSTALL_DIR) $(DESTDIR)$(QREXECSERVICEDIR)
	$(INSTALL_PROGRAM) qubes-rpc/services/qvc.Webcam qubes-rpc/services/qvc.ScreenShare $(DESTDIR)$(QREXECSERVICEDIR)
	$(INSTALL_DIR) $(DESTDIR)$(DATADIR)/$(PKGNAME)/sender
	$(INSTALL_PROGRAM) sender/*.py $(DESTDIR)$(DATADIR)/$(PKGNAME)/sender
	$(INSTALL_DIR) $(DESTDIR)$(DATADIR)/doc/$(PKGNAME)
	$(INSTALL_DATA) README.md doc/pipeline.md $(DESTDIR)$(DATADIR)/doc/$(PKGNAME)
	$(INSTALL_DIR) $(DESTDIR)$(DATADIR)/doc/$(PKGNAME)/visualizations
	$(INSTALL_DATA) doc/visualizations/* $(DESTDIR)$(DATADIR)/doc/$(PKGNAME)/visualizations

install-policy:
	$(INSTALL_DIR) $(DESTDIR)$(QREXECPOLICYDIR)
	$(INSTALL_DATA) qubes-rpc/policies/* $(DESTDIR)$(QREXECPOLICYDIR)

install-tests:
	cd tests && $(PYTHON) setup.py install -O1 --root $(DESTDIR)

install-license:
	$(INSTALL_DIR) $(DESTDIR)$(DATADIR)/licenses/$(PKGNAME)
	$(INSTALL_DATA) LICENSE $(DESTDIR)$(DATADIR)/licenses/$(PKGNAME)

clean:
	$(MAKE) -C doc clean
.PHONY: clean install-license install-policy install-both install-dom0 install-v4l2loopback-script build help
