# NOTE: Derived from blib/lib/Inline.pm.
# Changes made here will be lost when autosplit is run again.
# See AutoSplit.pm.
package Inline;

#line 1492 "blib/lib/Inline.pm (autosplit into blib/lib/auto/Inline/M09_marker_mismatch.al)"
sub M09_marker_mismatch {
    my ($marker, $lang) = @_;
    return <<END;
Marker '$marker' does not match Inline '$lang' section.

END
}

# end of Inline::M09_marker_mismatch
1;
