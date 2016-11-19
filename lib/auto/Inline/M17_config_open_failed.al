# NOTE: Derived from blib/lib/Inline.pm.
# Changes made here will be lost when autosplit is run again.
# See AutoSplit.pm.
package Inline;

#line 1561 "blib/lib/Inline.pm (autosplit into blib/lib/auto/Inline/M17_config_open_failed.al)"
sub M17_config_open_failed {
    my ($dir) = @_;
    my $file = File::Spec->catfile(${dir}, $configuration_file);
    return <<END;
Can't open ${file} for input.

END
#'
}

# end of Inline::M17_config_open_failed
1;
