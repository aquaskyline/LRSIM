# NOTE: Derived from blib/lib/Inline.pm.
# Changes made here will be lost when autosplit is run again.
# See AutoSplit.pm.
package Inline;

#line 1826 "blib/lib/Inline.pm (autosplit into blib/lib/auto/Inline/M41_usage_install_version_mismatch.al)"
sub M41_usage_install_version_mismatch {
    my ($mod_name, $mod_ver, $ext_name, $ext_ver) = @_;
    <<END;
The version '$mod_ver' for module '$mod_name' doe not match
the version '$ext_ver' for Inline section '$ext_name'.

END
}

# end of Inline::M41_usage_install_version_mismatch
1;
