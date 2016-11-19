# NOTE: Derived from blib/lib/Inline.pm.
# Changes made here will be lost when autosplit is run again.
# See AutoSplit.pm.
package Inline;

#line 1265 "blib/lib/Inline.pm (autosplit into blib/lib/auto/Inline/rmpath.al)"
#==============================================================================
# Nuke a path (nicely)
#==============================================================================
sub rmpath {
    use strict;
    my ($o, $prefix, $rmpath) = @_;
# Nuke the target directory
    _rmtree(File::Spec->catdir($prefix ? ($prefix,$rmpath) : ($rmpath)));
# Remove any empty directories underneath the requested one
    my @parts = File::Spec->splitdir($rmpath);
    while (@parts){
        $rmpath = File::Spec->catdir($prefix ? ($prefix,@parts) : @parts);
        ($rmpath) = $rmpath =~ /(.*)/ if UNTAINT;
        rmdir $rmpath
	  or last; # rmdir failed because dir was not empty
	pop @parts;
    }
}

# end of Inline::rmpath
1;
