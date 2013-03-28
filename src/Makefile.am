## Process this file with automake to produce Makefile.in

## Created by Anjuta


uidir = $(pkgdatadir)/ui


AM_CPPFLAGS = \
	-DPACKAGE_LOCALE_DIR=\""$(localedir)"\" \
	-DPACKAGE_SRC_DIR=\""$(srcdir)"\" \
	-DPACKAGE_DATA_DIR=\""$(pkgdatadir)"\" \
	$(THEODORATRANSCODE_CFLAGS) \
	$(glib-2.0_CFLAGS) \
	$(json-glib-1.0_CFLAGS)

AM_CFLAGS =\
	 -Wall\
	 -g

bin_PROGRAMS = theodoratranscode

theodoratranscode_SOURCES = \
	theodoratranscode.vala \
	config.vapi \
	theodoratranscode.ui \
	command.vala \
	widgets-query.vala \
	widgets-behaviour.vala \
	widgets-feedback.vala \
	widgets-adjutment.vala \
	widgets-profile.vala \
	file.vala \
	theodoratranscode.desktop

theodoratranscode_VALAFLAGS =  \
	--pkg gtk+-3.0 \
	--pkg json-glib-1.0 \
	--pkg glib-2.0   

theodoratranscode_LDFLAGS = \
	-Wl,--export-dynamic

theodoratranscode_LDADD = $(THEODORATRANSCODE_LIBS) \
	-lm

theodoratranscodeEXTRA_DIST = saving.vala 

EXTRA_DIST = $(ui_DATA)

# Remove ui directory on uninstall
uninstall-local:
	-rm -r $(uidir)
	-rm -r $(pkgdatadir)

