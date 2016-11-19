# NOTE: Derived from blib/lib/Inline.pm.
# Changes made here will be lost when autosplit is run again.
# See AutoSplit.pm.
package Inline;

#line 1941 "blib/lib/Inline.pm (autosplit into blib/lib/auto/Inline/M55_unlink_failed.al)"
sub M55_unlink_failed {
    my ($file) = @_;
    return <<END;
Can't unlink file '$file':

$!

END
#'
}

# end of Inline::M55_unlink_failed
1;
