# NOTE: Derived from blib/lib/Inline.pm.
# Changes made here will be lost when autosplit is run again.
# See AutoSplit.pm.
package Inline;

#line 1892 "blib/lib/Inline.pm (autosplit into blib/lib/auto/Inline/M49_usage_unsafe.al)"
sub M49_usage_unsafe {
    my ($terminate) = @_;
    return <<END .
You are using the Inline.pm module with the UNTAINT and SAFEMODE options,
but without specifying the DIRECTORY option. This is potentially unsafe.
Either use the DIRECTORY option or turn off SAFEMODE.

END
      ($terminate ? <<END : "");
Since you are running as a privileged user, Inline.pm is terminating.

END
}

# end of Inline::M49_usage_unsafe
1;
