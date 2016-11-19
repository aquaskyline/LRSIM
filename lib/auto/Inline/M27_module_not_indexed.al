# NOTE: Derived from blib/lib/Inline.pm.
# Changes made here will be lost when autosplit is run again.
# See AutoSplit.pm.
package Inline;

#line 1676 "blib/lib/Inline.pm (autosplit into blib/lib/auto/Inline/M27_module_not_indexed.al)"
sub M27_module_not_indexed {
    my ($mod) = @_;
    return <<END;
You are attempting to load an extension for '$mod',
but there is no entry for that module in %INC.

END
}

# end of Inline::M27_module_not_indexed
1;
