# NOTE: Derived from blib/lib/Inline.pm.
# Changes made here will be lost when autosplit is run again.
# See AutoSplit.pm.
package Inline;

#line 1456 "blib/lib/Inline.pm (autosplit into blib/lib/auto/Inline/M05_error_eval.al)"
sub M05_error_eval {
    my ($subroutine, $msg) = @_;
    return <<END;
An eval() failed in Inline::$subroutine:
$msg

END
}

# end of Inline::M05_error_eval
1;
