# NOTE: Derived from blib/lib/Inline.pm.
# Changes made here will be lost when autosplit is run again.
# See AutoSplit.pm.
package Inline;

#line 1731 "blib/lib/Inline.pm (autosplit into blib/lib/auto/Inline/M32_error_md5_validation.al)"
sub M32_error_md5_validation {
    my ($md5, $inl) = @_;
    return <<END;
The source code fingerprint:

    $md5

does not match the one in:

    $inl

This module needs to be reinstalled.

END
}

# end of Inline::M32_error_md5_validation
1;
