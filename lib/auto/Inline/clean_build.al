# NOTE: Derived from blib/lib/Inline.pm.
# Changes made here will be lost when autosplit is run again.
# See AutoSplit.pm.
package Inline;

#line 1088 "blib/lib/Inline.pm (autosplit into blib/lib/auto/Inline/clean_build.al)"
#==============================================================================
# Clean the build directory from previous builds
#==============================================================================
sub clean_build {
    use strict;
    my ($prefix, $dir);
    my $o = shift;

    $prefix = $o->{INLINE}{DIRECTORY};
    opendir(BUILD, $prefix)
      or croak "Can't open build directory: $prefix for cleanup $!\n";

    while ($dir = readdir(BUILD)) {
        my $maybedir = File::Spec->catdir($prefix,$dir);
        if (($maybedir and -d $maybedir) and ($dir =~ /\w{36,}/)) {
            $o->rmpath($prefix,$dir);
	}
    }

    close BUILD;
}

# end of Inline::clean_build
1;
