# NOTE: Derived from blib/lib/Inline.pm.
# Changes made here will be lost when autosplit is run again.
# See AutoSplit.pm.
package Inline;

#line 1319 "blib/lib/Inline.pm (autosplit into blib/lib/auto/Inline/find_temp_dir.al)"
#==============================================================================
# Find the 'Inline' directory to use.
#==============================================================================
my $TEMP_DIR;
sub find_temp_dir {
    return $TEMP_DIR if $TEMP_DIR;

    my ($temp_dir, $home, $bin, $cwd, $env);
    $temp_dir = '';
    $env = $ENV{PERL_INLINE_DIRECTORY} || '';
    $home = $ENV{HOME} ? abs_path($ENV{HOME}) : '';

    if ($env and
	-d $env and
	-w $env) {
	$temp_dir = $env;
    }
    elsif ($cwd = abs_path('.') and
	   $cwd ne $home and
           -d File::Spec->catdir($cwd,".Inline") and
           -w File::Spec->catdir($cwd,".Inline")) {
        $temp_dir = File::Spec->catdir($cwd,".Inline");
    }
       else {
               require FindBin ;
        if ($bin = $FindBin::Bin and
               -d File::Spec->catdir($bin,".Inline") and
               -w File::Spec->catdir($bin,".Inline")) {
            $temp_dir = File::Spec->catdir($bin,".Inline");
        }
        elsif ($home and
               -d File::Spec->catdir($home,".Inline") and
               -w File::Spec->catdir($home,".Inline")) {
            $temp_dir = File::Spec->catdir($home,".Inline");
        }
        elsif (defined $cwd and $cwd and
               -d File::Spec->catdir($cwd, $did) and
               -w File::Spec->catdir($cwd, $did)) {
            $temp_dir = File::Spec->catdir($cwd, $did);
        }
        elsif (defined $bin and $bin and
               -d File::Spec->catdir($bin, $did) and
               -w File::Spec->catdir($bin, $did)) {
            $temp_dir = File::Spec->catdir($bin, $did);
        }
        elsif (defined $cwd and $cwd and
          -d $cwd and
          -w $cwd and
               _mkdir(File::Spec->catdir($cwd, $did), 0777)) {
            $temp_dir = File::Spec->catdir($cwd, $did);
        }
        elsif (defined $bin and $bin and
          -d $bin and
          -w $bin and
               _mkdir(File::Spec->catdir($bin, $did), 0777)) {
            $temp_dir = File::Spec->catdir($bin, $did);
        }
       }

    croak M56_no_DIRECTORY_found()
      unless $temp_dir;
    return $TEMP_DIR = abs_path($temp_dir);
}

# end of Inline::find_temp_dir
1;
