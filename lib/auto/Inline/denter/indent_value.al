# NOTE: Derived from blib/lib/Inline/denter.pm.
# Changes made here will be lost when autosplit is run again.
# See AutoSplit.pm.
package Inline::denter;

#line 245 "blib/lib/Inline/denter.pm (autosplit into blib/lib/auto/Inline/denter/indent_value.al)"
sub indent_value {
    my ($o, $data) = @_;
    my $stream;
    if ($data =~ /\n/) {
	my $marker = 'EOV';
	$marker++ while $data =~ /^$marker$/m;
	my $chomp = ($data =~ s/\n\Z//) ? '' : '-';
	$stream = "<<$marker$chomp\n";
	$stream .= $o->{key}, $o->{key} = '' if $o->{key};
	$stream .= "$data\n$marker\n";
    }
    elsif ($data =~ /^[\s\%\@\$\\?\"]|\s$/ or
	   $data =~ /\Q$o->{comma}\E/ or
	   $data =~ /[\x00-\x1f]/ or
	   $data eq '') {
	$stream = qq{"$data"\n};
	$stream .= $o->{key}, $o->{key} = '' if $o->{key};
    }
    else {
	$stream = "$data\n";
	$stream .= $o->{key}, $o->{key} = '' if $o->{key};
    }
    return $stream;
}

# end of Inline::denter::indent_value
1;
