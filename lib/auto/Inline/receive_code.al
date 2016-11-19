# NOTE: Derived from blib/lib/Inline.pm.
# Changes made here will be lost when autosplit is run again.
# See AutoSplit.pm.
package Inline;

#line 640 "blib/lib/Inline.pm (autosplit into blib/lib/auto/Inline/receive_code.al)"
#==============================================================================
# Get the source code
#==============================================================================
sub receive_code {
    my $o = shift;
    my $code = shift;

    croak M02_usage() unless (defined $code and $code);

    if (ref $code eq 'CODE') {
	$o->{API}{code} = &$code;
    }
    elsif (ref $code eq 'ARRAY') {
        $o->{API}{code} = join '', @$code;
    }
    elsif ($code =~ m|[/\\:]| and
           $code =~ m|^[/\\:\w.\-\ \$\[\]<>]+$|) {
	if (-f $code) {
	    local ($/, *CODE);
	    open CODE, "< $code" or croak M06_code_file_failed_open($code);
	    $o->{API}{code} = <CODE>;
	}
	else {
	    croak M07_code_file_does_not_exist($code);
	}
    }
    else {
	$o->{API}{code} = $code;
    }
}

# end of Inline::receive_code
1;
