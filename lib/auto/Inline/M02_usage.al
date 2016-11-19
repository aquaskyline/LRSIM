# NOTE: Derived from blib/lib/Inline.pm.
# Changes made here will be lost when autosplit is run again.
# See AutoSplit.pm.
package Inline;

#line 1408 "blib/lib/Inline.pm (autosplit into blib/lib/auto/Inline/M02_usage.al)"
sub M02_usage {
    my $usage = <<END;
Invalid usage of Inline module. Valid usages are:
    use Inline;
    use Inline language => "source-string", config-pair-list;
    use Inline language => "source-file", config-pair-list;
    use Inline language => [source-line-list], config-pair-list;
    use Inline language => 'DATA', config-pair-list;
    use Inline language => 'Config', config-pair-list;
    use Inline Config => config-pair-list;
    use Inline with => module-list;
    use Inline shortcut-list;
END
# This is broken ????????????????????????????????????????????????????
    $usage .= <<END if defined $Inline::languages;

Supported languages:
    ${\ join(', ', sort keys %$Inline::languages)}

END
    return $usage;
}

# end of Inline::M02_usage
1;
