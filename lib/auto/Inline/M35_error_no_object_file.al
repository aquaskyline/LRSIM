# NOTE: Derived from blib/lib/Inline.pm.
# Changes made here will be lost when autosplit is run again.
# See AutoSplit.pm.
package Inline;

#line 1772 "blib/lib/Inline.pm (autosplit into blib/lib/auto/Inline/M35_error_no_object_file.al)"
sub M35_error_no_object_file {
    my ($obj, $inl) = @_;
    return <<END;
There is no object file:
    $obj

For Inline validation file:
    $inl

This module should be reinstalled.

END
}

# end of Inline::M35_error_no_object_file
1;
