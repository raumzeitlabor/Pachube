#!/usr/bin/env perl
# vim:ts=4:sw=4:expandtab
use strict;
use warnings;
use inc::Module::Install;

name     'ElectricityPachube';
all_from 'lib/RaumZeitLabor/ElectricityPachube.pm';

#requires 'AnyEvent';
#requires 'AnyEvent::HTTP';
#requires 'AnyEvent::HTTP::Stream';
#requires 'JSON::XS';
#requires 'YAML::Syck';
#requires 'DBI';
#requires 'DBD::mysql';
#requires 'String::CRC32';
#requires 'Try::Tiny';

install_script 'electricity-pachube';

postamble <<'END_OF_MAKEFILE';
install:: extra_install
pure_install:: extra_install
install_vendor:: extra_install

extra_install:
	install -d $(DESTDIR)/etc/
	install -m 640 electricity-pachube.yml.ex $(DESTDIR)/etc/electricity-pachube.yml
END_OF_MAKEFILE

WriteAll;
