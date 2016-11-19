# NOTE: Derived from blib/lib/Inline.pm.
# Changes made here will be lost when autosplit is run again.
# See AutoSplit.pm.
package Inline;

#line 1391 "blib/lib/Inline.pm (autosplit into blib/lib/auto/Inline/M01_usage_use.al)"
# Comment out the next 2 lines to stop autoloading of messages (for testing)
#1;
#__END__

#==============================================================================
# Error messages are autoloaded
#==============================================================================

sub M01_usage_use {
    my ($module) = @_;
    return <<END;
It is invalid to use '$module' directly. Please consult the Inline
documentation for more information.

END
}

# end of Inline::M01_usage_use
1;
