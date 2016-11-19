# NOTE: Derived from blib/lib/Inline.pm.
# Changes made here will be lost when autosplit is run again.
# See AutoSplit.pm.
package Inline;

#line 1524 "blib/lib/Inline.pm (autosplit into blib/lib/auto/Inline/M13_usage_VERSION.al)"
sub M13_usage_VERSION {
    my ($version) = @_;
    return <<END;
Invalid value for VERSION config option: '$version'
Must be of the form '#.##'.
(Should also be specified as a string rather than a floating point number)

END
}

# end of Inline::M13_usage_VERSION
1;
