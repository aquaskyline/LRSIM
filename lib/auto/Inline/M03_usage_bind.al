# NOTE: Derived from blib/lib/Inline.pm.
# Changes made here will be lost when autosplit is run again.
# See AutoSplit.pm.
package Inline;

#line 1431 "blib/lib/Inline.pm (autosplit into blib/lib/auto/Inline/M03_usage_bind.al)"
sub M03_usage_bind {
    my $usage = <<END;
Invalid usage of the Inline->bind() function. Valid usages are:
    Inline->bind(language => "source-string", config-pair-list);
    Inline->bind(language => "source-file", config-pair-list);
    Inline->bind(language => [source-line-list], config-pair-list);
END

    $usage .= <<END if defined $Inline::languages;

Supported languages:
    ${\ join(', ', sort keys %$Inline::languages)}

END
    return $usage;
}

# end of Inline::M03_usage_bind
1;
