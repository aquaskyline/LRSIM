# NOTE: Derived from blib/lib/Inline/denter.pm.
# Changes made here will be lost when autosplit is run again.
# See AutoSplit.pm.
package Inline::denter;

#line 212 "blib/lib/Inline/denter.pm (autosplit into blib/lib/auto/Inline/denter/indent.al)"
sub indent {
    my $o = shift;
    my $package = caller;
    $package = caller(1) if $package eq 'Inline::denter';
    my $stream = '';
    $o->{key} = '';
    while (@_) {
	local $_ = shift;
	$stream .= $o->indent_name($_, shift), next
	  if (/^\*$package\::\w+$/);
	$stream .= $o->indent_data($_);
    }
    return $stream;
}

# end of Inline::denter::indent
1;
