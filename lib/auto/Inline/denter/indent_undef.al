# NOTE: Derived from blib/lib/Inline/denter.pm.
# Changes made here will be lost when autosplit is run again.
# See AutoSplit.pm.
package Inline::denter;

#line 326 "blib/lib/Inline/denter.pm (autosplit into blib/lib/auto/Inline/denter/indent_undef.al)"
sub indent_undef {
    my ($o, $data) = @_;
    my $stream = "?\n";
    $stream .= $o->{key}, $o->{key} = '' if $o->{key};
    return $stream;
}

# end of Inline::denter::indent_undef
1;
