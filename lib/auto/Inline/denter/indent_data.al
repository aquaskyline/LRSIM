# NOTE: Derived from blib/lib/Inline/denter.pm.
# Changes made here will be lost when autosplit is run again.
# See AutoSplit.pm.
package Inline::denter;

#line 227 "blib/lib/Inline/denter.pm (autosplit into blib/lib/auto/Inline/denter/indent_data.al)"
sub indent_data {
    my $o = shift;
    local $_ = shift;
    return $o->indent_undef($_)
      if not defined;
    return $o->indent_value($_)
      if (not ref);
    return $o->indent_hash($_)
      if (ref eq 'HASH' and not /=/ or /=HASH/);
    return $o->indent_array($_)
      if (ref eq 'ARRAY' and not /=/ or /=ARRAY/);
    return $o->indent_scalar($_)
      if (ref eq 'SCALAR' and not /=/ or /=SCALAR/);
    return $o->indent_ref($_)
      if (ref eq 'REF');
    return "$_\n";
}

# end of Inline::denter::indent_data
1;
