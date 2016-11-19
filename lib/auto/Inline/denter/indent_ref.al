# NOTE: Derived from blib/lib/Inline/denter.pm.
# Changes made here will be lost when autosplit is run again.
# See AutoSplit.pm.
package Inline::denter;

#line 318 "blib/lib/Inline/denter.pm (autosplit into blib/lib/auto/Inline/denter/indent_ref.al)"
sub indent_ref {
    my ($o, $data) = @_;
    my $stream = $o->_print_ref($data, '\\', 'SCALAR');
    return $$stream if ref $stream;
    chomp $stream;
    return $stream . $o->indent_data($$data);
}

# end of Inline::denter::indent_ref
1;
