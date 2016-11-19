# NOTE: Derived from blib/lib/Inline.pm.
# Changes made here will be lost when autosplit is run again.
# See AutoSplit.pm.
package Inline;

#line 1842 "blib/lib/Inline.pm (autosplit into blib/lib/auto/Inline/M43_error_bootstrap.al)"
sub M43_error_bootstrap {
    my ($mod, $err) = @_;
    return <<END;
Had problems bootstrapping Inline module '$mod'

$err

END
}

# end of Inline::M43_error_bootstrap
1;
