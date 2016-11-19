# NOTE: Derived from blib/lib/Inline.pm.
# Changes made here will be lost when autosplit is run again.
# See AutoSplit.pm.
package Inline;

#line 1880 "blib/lib/Inline.pm (autosplit into blib/lib/auto/Inline/M48_usage_shortcuts.al)"
sub M48_usage_shortcuts {
    my ($shortcut) = @_;
    return <<END;
Invalid shortcut '$shortcut' specified.

Valid shortcuts are:
    VERSION, INFO, FORCE, NOCLEAN, CLEAN, UNTAINT, SAFE, UNSAFE,
    GLOBAL, NOISY and REPORTBUG

END
}

# end of Inline::M48_usage_shortcuts
1;
