# NOTE: Derived from blib/lib/Inline/denter.pm.
# Changes made here will be lost when autosplit is run again.
# See AutoSplit.pm.
package Inline::denter;

#line 341 "blib/lib/Inline/denter.pm (autosplit into blib/lib/auto/Inline/denter/_print_ref.al)"
sub _print_ref {
    my ($o, $data, $symbol, $type) = @_;
    $data =~ /^(([\w:]+)=)?$type\(0x([0-9a-f]+)\)$/
      or croak "Invalid reference: $data\n";
    my $stream = $symbol;
    $stream .= $2 if defined $2;
    $o->{xref}{$3}++;
    croak "Inline::denter does not handle duplicate references"
      if $o->{xref}{$3} > 1;
    $stream .= "\n";
    $stream .= $o->{key}, $o->{key} = '' if $o->{key};
    return $stream;
}

# end of Inline::denter::_print_ref
1;
