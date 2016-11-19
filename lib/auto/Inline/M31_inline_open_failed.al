# NOTE: Derived from blib/lib/Inline.pm.
# Changes made here will be lost when autosplit is run again.
# See AutoSplit.pm.
package Inline;

#line 1718 "blib/lib/Inline.pm (autosplit into blib/lib/auto/Inline/M31_inline_open_failed.al)"
sub M31_inline_open_failed {
    my ($file) = @_;
    return <<END;
Can't open Inline validate file:

    $file

$!

END
#'
}

# end of Inline::M31_inline_open_failed
1;
