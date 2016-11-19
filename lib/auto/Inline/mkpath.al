# NOTE: Derived from blib/lib/Inline.pm.
# Changes made here will be lost when autosplit is run again.
# See AutoSplit.pm.
package Inline;

#line 1243 "blib/lib/Inline.pm (autosplit into blib/lib/auto/Inline/mkpath.al)"
#==============================================================================
# Utility subroutines
#==============================================================================

#==============================================================================
# Make a path
#==============================================================================
sub mkpath {
    use strict;
    my ($o, $mkpath) = @_;
    my($volume,$dirs,$nofile) = File::Spec->splitpath($mkpath,1);
    my @parts = File::Spec->splitdir($dirs);
    my @done;
    foreach (@parts){
        push(@done,$_);
        my $path = File::Spec->catpath($volume,File::Spec->catdir(@done),"");
        -d $path || _mkdir($path, 0777);
    }
    croak M53_mkdir_failed($mkpath)
      unless -d $mkpath;
}

# end of Inline::mkpath
1;
