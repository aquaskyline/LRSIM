# NOTE: Derived from blib/lib/Inline.pm.
# Changes made here will be lost when autosplit is run again.
# See AutoSplit.pm.
package Inline;

#line 1658 "blib/lib/Inline.pm (autosplit into blib/lib/auto/Inline/M25_no_WITH_support.al)"
sub M25_no_WITH_support {
    my ($mod, $err) = @_;
    return <<END;
You have requested "use Inline with => '$mod'"
but '$mod' does not work with Inline.

$err

END
}

# end of Inline::M25_no_WITH_support
1;
