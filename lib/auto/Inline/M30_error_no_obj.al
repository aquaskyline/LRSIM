# NOTE: Derived from blib/lib/Inline.pm.
# Changes made here will be lost when autosplit is run again.
# See AutoSplit.pm.
package Inline;

#line 1703 "blib/lib/Inline.pm (autosplit into blib/lib/auto/Inline/M30_error_no_obj.al)"
sub M30_error_no_obj {
    my ($name, $pkg, $path) = @_;
    <<END;
The extension '$name' is not properly installed in path:
  '$path'

If this is a CPAN/distributed module, you may need to reinstall it on your
system.

To allow Inline to compile the module in a temporary cache, simply remove the
Inline config option 'VERSION=' from the $pkg module.

END
}

# end of Inline::M30_error_no_obj
1;
