dnl Macros to enable Native Language Support (NLS)
dnl If you add a new language, be sure to add the code to all the macros
dnl Try to keep the languages alphabetical (de, en, fr, zh)
dnl
define(Get_Language_Deps, po/r3r$(MESSAGES_TEMPLATE) ifdef(`USE_NLS', po/en$(MESSAGES_COMPILED) po/eo$(MESSAGES_COMPILED)))dnl
define(Install_Langs,
	-$(MKDIR) $(localedir)/en/LC_MESSAGES
	-$(MKDIR) $(localedir)/eo/LC_MESSAGES
	$(INSTALL) po/en$(MOEXT) $(localedir)/en/LC_MESSAGES/r3r$(MESSAGES_COMPILED)
	$(INSTALL) po/eo$(MOEXT) $(localedir)/eo/LC_MESSAGES/r3r$(MESSAGES_COMPILED))dnl
define(Uninstall_Langs,
	$(RM) $(localedir)/en/LC_MESSAGES/r3r$(MESSAGES_COMPILED)
	$(RM) $(localedir)/eo/LC_MESSAGES/r3r$(MESSAGES_COMPILED))dnl
define(Ap_Copy_Langs, ifdef(`USE_NLS',
copyFiles en.mo "$PREFIX/share/locale/en/LC_MESSAGES/r3r.mo"
copyFiles eo.mo "$PREFIX/share/locale/eo/LC_MESSAGES/r3r.mo"))dnl
define(Is_Install_Langs, ifdef(`USE_NLS',
Source: "..\..\po\en.mo"; DestDir: "{app}\share\locale\en\LC_MESSAGES\r3r.mo";
Source: "..\..\po\eo.mo"; DestDir: "{app}\share\locale\eo\LC_MESSAGES\r3r.mo";))dnl
