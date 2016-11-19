# NOTE: Derived from blib/lib/Inline/denter.pm.
# Changes made here will be lost when autosplit is run again.
# See AutoSplit.pm.
package Inline::denter;

#line 295 "blib/lib/Inline/denter.pm (autosplit into blib/lib/auto/Inline/denter/indent_array.al)"
sub indent_array {
    my ($o, $data) = @_;
    my $stream = $o->_print_ref($data, '@', 'ARRAY');
    return $$stream if ref $stream;
    my $indent = ++$o->{level} * $o->{width};
    for my $datum (@$data) {
	$stream .= ' ' x $indent;
	$stream .= $o->indent_data($datum);
    }
    $o->{level}--;
    return $stream;
}

# end of Inline::denter::indent_array
1;
