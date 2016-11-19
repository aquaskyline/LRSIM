# NOTE: Derived from blib/lib/Inline.pm.
# Changes made here will be lost when autosplit is run again.
# See AutoSplit.pm.
package Inline;

#line 1110 "blib/lib/Inline.pm (autosplit into blib/lib/auto/Inline/filter.al)"
#==============================================================================
# Apply a list of filters to the source code
#==============================================================================
sub filter {
    my $o = shift;
    my $new_code = $o->{API}{code};
    for (@_) {
	croak M52_invalid_filter($_) unless ref;
	if (ref eq 'CODE') {
	    $new_code = $_->($new_code);
	}
	else {
	    $new_code = $_->filter($o, $new_code);
	}
    }
    return $new_code;
}

# end of Inline::filter
1;
