# NOTE: Derived from blib/lib/Inline/denter.pm.
# Changes made here will be lost when autosplit is run again.
# See AutoSplit.pm.
package Inline::denter;

#line 270 "blib/lib/Inline/denter.pm (autosplit into blib/lib/auto/Inline/denter/indent_hash.al)"
sub indent_hash {
    my ($o, $data) = @_;
    my $stream = $o->_print_ref($data, '%', 'HASH');
    return $$stream if ref $stream;
    my $indent = ++$o->{level} * $o->{width};
    for my $key (sort keys %$data) {
	my $key_out = $key;
	if ($key =~ /\n/ or
	    $key =~ /\Q$o->{comma}\E/) {
	    my $marker = 'EOK';
	    $marker++ while $key =~ /^$marker$/m;
	    my $chomp = (($o->{key} = $key) =~ s/\n\Z//m) ? '' : '-';
	    $o->{key} .= "\n$marker\n";
	    $key_out = "<<$marker$chomp";
	}
	elsif ($data =~ /^[\s\%\@\$\\?\"]|\s$/) {
	    $key_out = qq{"$key"};
	}
	$stream .= ' ' x $indent . $key_out . $o->{comma};
	$stream .= $o->indent_data($data->{$key});
    }
    $o->{level}--;
    return $stream;
}

# end of Inline::denter::indent_hash
1;
