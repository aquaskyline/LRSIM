# NOTE: Derived from blib/lib/Inline.pm.
# Changes made here will be lost when autosplit is run again.
# See AutoSplit.pm.
package Inline;

#line 1816 "blib/lib/Inline.pm (autosplit into blib/lib/auto/Inline/M40_usage_install_badname.al)"
sub M40_usage_install_badname {
    my ($name, $pkg) = @_;
    return <<END;
The NAME '$name' is illegal for this Inline extension.
The NAME must match the current package name:
    $pkg

END
}

# end of Inline::M40_usage_install_badname
1;
