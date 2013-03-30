## Process this file with automake to produce Makefile.in

## Created by Anjuta


uidir = $(pkgdatadir)/ui
ui_DATA = theodoratranscode.ui


AM_CPPFLAGS = \
	-DPACKAGE_LOCALE_DIR=\""$(localedir)"\" \
	-DPACKAGE_SRC_DIR=\""$(srcdir)"\" \
	-DPACKAGE_DATA_DIR=\""$(pkgdatadir)"\" \
	$(THEODORATRANSCODE_C_CFLAGS)

AM_CFLAGS =\
	 -Wall\
	 -g

bin_PROGRAMS = theodoratranscode_c

theodoratranscode_c_SOURCES =  \
	theodoratranscode.c \
	widgets-adjutment.c \
	command.c \
	widgets-profile.c \
	file.c \
	widgets-behaviour.c \
	widgets-feedback.c \
	widgets-query.c

theodoratranscode_c_LDFLAGS = \
	-Wl,--export-dynamic

theodoratranscode_c_LDADD = $(THEODORATRANSCODE_C_LIBS)


EXTRA_DIST = $(ui_DATA)

# Remove ui directory on uninstall
uninstall-local:
	-rm -r $(uidir)
	-rm -r $(pkgdatadir)

