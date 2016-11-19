# NOTE: Derived from blib/lib/Inline.pm.
# Changes made here will be lost when autosplit is run again.
# See AutoSplit.pm.
package Inline;

#line 1960 "blib/lib/Inline.pm (autosplit into blib/lib/auto/Inline/M57_wrong_architecture.al)"
sub M57_wrong_architecture {
    my ($ext, $arch, $thisarch) = @_;
    return <<END;
The extension '$ext'
is built for perl on the '$arch' platform.
This is the '$thisarch' platform.

END
}

# end of Inline::M57_wrong_architecture
1;
