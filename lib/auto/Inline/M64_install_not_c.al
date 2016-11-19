# NOTE: Derived from blib/lib/Inline.pm.
# Changes made here will be lost when autosplit is run again.
# See AutoSplit.pm.
package Inline;

#line 2028 "blib/lib/Inline.pm (autosplit into blib/lib/auto/Inline/M64_install_not_c.al)"
sub M64_install_not_c {
    my ($lang) = @_;
    return <<END;
Invalid attempt to install an Inline module using the '$lang' language.

Only C and CPP (C++) based modules are currently supported.

END
}

1;
__END__
1;
# end of Inline::M64_install_not_c
