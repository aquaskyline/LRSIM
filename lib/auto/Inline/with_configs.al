# NOTE: Derived from blib/lib/Inline.pm.
# Changes made here will be lost when autosplit is run again.
# See AutoSplit.pm.
package Inline;

#line 1031 "blib/lib/Inline.pm (autosplit into blib/lib/auto/Inline/with_configs.al)"
#==============================================================================
# Get config hints
#==============================================================================
sub with_configs {
    my $o = shift;
    my @configs;
    for my $mod (@{$o->{CONFIG}{WITH}}) {
	my $ref = eval {
	    no strict 'refs';
	    &{$mod . "::Inline"}($o->{API}{language});
	};
	croak M25_no_WITH_support($mod, $@) if $@;
	push @configs, %$ref;
    }
    return @configs;
}

# end of Inline::with_configs
1;
