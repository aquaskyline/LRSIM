# NOTE: Derived from blib/lib/Inline.pm.
# Changes made here will be lost when autosplit is run again.
# See AutoSplit.pm.
package Inline;

#line 1759 "blib/lib/Inline.pm (autosplit into blib/lib/auto/Inline/M34_error_incorrect_version.al)"
sub M34_error_incorrect_version {
    my ($inl) = @_;
    return <<END;
The version of your extension does not match the one indicated by your
Inline source code, according to:

    $inl

This module should be reinstalled.

END
}

# end of Inline::M34_error_incorrect_version
1;
