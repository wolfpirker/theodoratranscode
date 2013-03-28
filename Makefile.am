## Process this file with automake to produce Makefile.in
## Created by Anjuta

SUBDIRS = src 

theodoratranscodedocdir = ${prefix}/doc/theodoratranscode
theodoratranscodedoc_DATA = \
	AUTHORS\
	ChangeLog\
	INSTALL\
	NEWS\
	LICENSE\
	README.md


EXTRA_DIST = $(theodoratranscodedoc_DATA)


# Remove doc directory on uninstall
uninstall-local:
	-rm -r $(theodoratranscodedocdir)
