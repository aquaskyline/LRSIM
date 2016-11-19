# NOTE: Derived from blib/lib/Inline.pm.
# Changes made here will be lost when autosplit is run again.
# See AutoSplit.pm.
package Inline;

#line 1383 "blib/lib/Inline.pm (autosplit into blib/lib/auto/Inline/_mkdir.al)"
sub _mkdir {
    my $dir = shift;
    my $mode = shift || 0777;
    ($dir) = ($dir =~ /(.*)/) if UNTAINT;
    $dir =~ s|[/\\:]$||;
    return mkdir($dir, $mode);
}

# end of Inline::_mkdir
1;
