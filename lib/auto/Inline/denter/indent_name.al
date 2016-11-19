# NOTE: Derived from blib/lib/Inline/denter.pm.
# Changes made here will be lost when autosplit is run again.
# See AutoSplit.pm.
package Inline::denter;

#line 333 "blib/lib/Inline/denter.pm (autosplit into blib/lib/auto/Inline/denter/indent_name.al)"
sub indent_name {
    my ($o, $name, $value) = @_;
    $name =~ s/^.*:://;
    my $stream = $name . $o->{comma};
    $stream .= $o->indent_data($value);
    return $stream;
}

# end of Inline::denter::indent_name
1;
