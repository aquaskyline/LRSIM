# NOTE: Derived from blib/lib/Inline.pm.
# Changes made here will be lost when autosplit is run again.
# See AutoSplit.pm.
package Inline;

#line 1465 "blib/lib/Inline.pm (autosplit into blib/lib/auto/Inline/M06_code_file_failed_open.al)"
sub M06_code_file_failed_open {
    my ($file) = @_;
    return <<END;
Couldn't open Inline code file '$file':
$!

END
#'
}

# end of Inline::M06_code_file_failed_open
1;
