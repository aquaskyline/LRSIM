# NOTE: Derived from blib/lib/Inline.pm.
# Changes made here will be lost when autosplit is run again.
# See AutoSplit.pm.
package Inline;

#line 1284 "blib/lib/Inline.pm (autosplit into blib/lib/auto/Inline/_rmtree.al)"
sub _rmtree {
    my($roots) = @_;
    $roots = [$roots] unless ref $roots;
    my($root);
    foreach $root (@{$roots}) {
        if ( -d $root ) {
            my(@names,@paths);
            if (opendir MYDIR, $root) {
                @names = readdir MYDIR;
                closedir MYDIR;
            }
            else {
                croak M21_opendir_failed($root);
            }

            my $dot    = File::Spec->curdir();
            my $dotdot = File::Spec->updir();
            foreach my $name (@names) {
                next if $name eq $dot or $name eq $dotdot;
                my $maybefile = File::Spec->catfile($root,$name);
                push(@paths,$maybefile),next if $maybefile and -f $maybefile;
                push(@paths,File::Spec->catdir($root,$name));
            }

            _rmtree(\@paths);
	    ($root) = $root =~ /(.*)/ if UNTAINT;
            rmdir($root) or croak M54_rmdir_failed($root);
        }
        else {
	    ($root) = $root =~ /(.*)/ if UNTAINT;
	    unlink($root) or croak M55_unlink_failed($root);
        }
    }
}

# end of Inline::_rmtree
1;
