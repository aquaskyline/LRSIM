# NOTE: Derived from blib/lib/Inline.pm.
# Changes made here will be lost when autosplit is run again.
# See AutoSplit.pm.
package Inline;

#line 1571 "blib/lib/Inline.pm (autosplit into blib/lib/auto/Inline/M18_error_old_version.al)"
sub M18_error_old_version {
    my ($old_version, $directory) = @_;
    $old_version ||= '???';
    return <<END;
You are using Inline version $Inline::VERSION with a directory that was
configured by Inline version $old_version. This version is no longer supported.
Please delete the following directory and try again:

    $directory

END
}

# end of Inline::M18_error_old_version
1;
