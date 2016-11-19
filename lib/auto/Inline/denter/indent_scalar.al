# NOTE: Derived from blib/lib/Inline/denter.pm.
# Changes made here will be lost when autosplit is run again.
# See AutoSplit.pm.
package Inline::denter;

#line 308 "blib/lib/Inline/denter.pm (autosplit into blib/lib/auto/Inline/denter/indent_scalar.al)"
sub indent_scalar {
    my ($o, $data) = @_;
    my $stream = $o->_print_ref($data, q{$}, 'SCALAR');
    return $$stream if ref $stream;
    my $indent = ($o->{level} + 1) * $o->{width};
    $stream .= ' ' x $indent;
    $stream .= $o->indent_data($$data);
    return $stream;
}

# end of Inline::denter::indent_scalar
1;
