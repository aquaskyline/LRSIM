# NOTE: Derived from blib/lib/Inline.pm.
# Changes made here will be lost when autosplit is run again.
# See AutoSplit.pm.
package Inline;

#line 1862 "blib/lib/Inline.pm (autosplit into blib/lib/auto/Inline/M46_usage_with_bad.al)"
sub M46_usage_with_bad {
    my $mod = shift;
    return <<END;
Syntax error detected using 'use Inline with => "$mod";'.
'$mod' could not be found.

END
}

# end of Inline::M46_usage_with_bad
1;
