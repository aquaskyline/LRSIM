# NOTE: Derived from blib/lib/Inline.pm.
# Changes made here will be lost when autosplit is run again.
# See AutoSplit.pm.
package Inline;

#line 1605 "blib/lib/Inline.pm (autosplit into blib/lib/auto/Inline/M20_config_creation_failed.al)"
sub M20_config_creation_failed {
    my ($dir) = @_;
    my $file = File::Spec->catfile(${dir}, $configuration_file);
    return <<END;
Failed to autogenerate ${file}.

END
}

# end of Inline::M20_config_creation_failed
1;
