# NOTE: Derived from blib/lib/Inline.pm.
# Changes made here will be lost when autosplit is run again.
# See AutoSplit.pm.
package Inline;

#line 1930 "blib/lib/Inline.pm (autosplit into blib/lib/auto/Inline/M54_rmdir_failed.al)"
sub M54_rmdir_failed {
    my ($dir) = @_;
    return <<END;
Can't remove directory '$dir':

$!

END
#'
}

# end of Inline::M54_rmdir_failed
1;
