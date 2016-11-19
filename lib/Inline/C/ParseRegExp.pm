package Inline::C::ParseRegExp;
use strict;
use Carp;

sub register {
    {
     extends => [qw(C)],
     overrides => [qw(get_parser)],
    }
}

sub get_parser {
    Inline::C::_parser_test("Inline::C::ParseRegExp::get_parser called\n") if $_[0]->{CONFIG}{_TESTING};
    bless {}, 'Inline::C::ParseRegExp'
}

sub code {
    my($self,$code) = @_;

    # These regular expressions were derived from Regexp::Common v0.01.
    my $RE_comment_C   = q{(?:(?:\/\*)(?:(?:(?!\*\/)[\s\S])*)(?:\*\/))};
    my $RE_comment_Cpp = q{(?:\/\*(?:(?!\*\/)[\s\S])*\*\/|\/\/[^\n]*\n)};
    my $RE_quoted      = (q{(?:(?:\")(?:[^\\\"]*(?:\\.[^\\\"]*)*)(?:\")}
                         .q{|(?:\')(?:[^\\\']*(?:\\.[^\\\']*)*)(?:\'))});
    our $RE_balanced_brackets; $RE_balanced_brackets =
        qr'(?:[{]((?:(?>[^{}]+)|(??{$RE_balanced_brackets}))*)[}])';
    our $RE_balanced_parens; $RE_balanced_parens   =
        qr'(?:[(]((?:(?>[^()]+)|(??{$RE_balanced_parens}))*)[)])';

    # First, we crush out anything potentially confusing.
    # The order of these _does_ matter.
    $code =~ s/$RE_comment_C/ /go;
    $code =~ s/$RE_comment_Cpp/ /go;
    $code =~ s/^\#.*(\\\n.*)*//mgo;
    #$code =~ s/$RE_quoted/\"\"/go; # Buggy, if included.
    $code =~ s/$RE_balanced_brackets/{ }/go;

    $self->{_the_code_most_recently_parsed} = $code; # Simplifies debugging.

    my $normalize_type = sub {
	# Normalize a type for lookup in a typemap.
        my($type) = @_;

        # Remove "extern".
        # But keep "static", "inline", "typedef", etc,
        #  to cause desirable typemap misses.
        $type =~ s/\bextern\b//g;

        # Whitespace: only single spaces, none leading or trailing.
        $type =~ s/\s+/ /g;
        $type =~ s/^\s//; $type =~ s/\s$//;

        # Adjacent "derivative characters" are not separated by whitespace,
        # but _are_ separated from the adjoining text.
        # [ Is really only * (and not ()[]) needed??? ]
        $type =~ s/\*\s\*/\*\*/g;
        $type =~ s/(?<=[^ \*])\*/ \*/g;

        return $type;
    };

    # The decision of what is an acceptable declaration was originally
    # derived from Inline::C::grammar.pm version 0.30 (Inline 0.43).

    my $re_plausible_place_to_begin_a_declaration = qr {
	# The beginning of a line, possibly indented.
	# (Accepting indentation allows for C code to be aligned with
	#  its surrounding perl, and for backwards compatibility with
	#  Inline 0.43).
	(?m: ^ ) \s*
    }xo;

    # Instead of using \s , we dont tolerate blank lines.
    # This matches user expectation better than allowing arbitrary
    # vertical whitespace.
    my $sp = qr{[ \t]|\n(?![ \t]*\n)};

    my $re_type = qr {(
			(?: \w+ $sp* )+? # words
			(?: \*  $sp* )*  # stars
			)}xo;

    my $re_identifier = qr{ (\w+) $sp* }xo;

    while($code =~ m{
	$re_plausible_place_to_begin_a_declaration
        ( $re_type $re_identifier $RE_balanced_parens $sp* (\;|\{) )
       }xgo)
    {
        my($type, $identifier, $args, $what) = ($2,$3,$4,$5);
        $args = "" if $args =~ /^\s+$/;

        my $is_decl     = $what eq ';';
        my $function    = $identifier;
        my $return_type = &$normalize_type($type);
	my @arguments   = split ',', $args;

        goto RESYNC if $is_decl && !$self->{data}{AUTOWRAP};
        goto RESYNC if $self->{data}{done}{$function};
        goto RESYNC if !defined
            $self->{data}{typeconv}{valid_rtypes}{$return_type};

        my(@arg_names,@arg_types);
	my $dummy_name = 'arg1';

	foreach my $arg (@arguments) {
          my $arg_no_space = $arg;
          $arg_no_space =~ s/\s//g;
          # If $arg_no_space is 'void', there will be no identifier.
	    if(my($type, $identifier) =
	       $arg =~ /^\s*$re_type(?:$re_identifier)?\s*$/o)
	    {
		my $arg_name = $identifier;
		my $arg_type = &$normalize_type($type);

		if((!defined $arg_name) && ($arg_no_space ne 'void')) {
		    goto RESYNC if !$is_decl;
		    $arg_name = $dummy_name++;
		}
		goto RESYNC if ((!defined
		    $self->{data}{typeconv}{valid_types}{$arg_type}) && ($arg_no_space ne 'void'));

            # Push $arg_name onto @arg_names iff it's defined. Otherwise ($arg_no_space
            # was 'void'), push the empty string onto @arg_names (to avoid uninitialized
            # warnings emanating from C.pm).
		defined($arg_name) ? push(@arg_names,$arg_name)
                               : push(@arg_names, '');
            if($arg_name) {push(@arg_types,$arg_type)}
            else {push(@arg_types,'')} # $arg_no_space was 'void' - this push() avoids 'uninitialized' warnings from C.pm
	    }
	    elsif($arg =~ /^\s*\.\.\.\s*$/) {
		push(@arg_names,'...');
		push(@arg_types,'...');
	    }
	    else {
		goto RESYNC;
	    }
	}

        # Commit.
        push @{$self->{data}{functions}}, $function;
        $self->{data}{function}{$function}{return_type}= $return_type;
        $self->{data}{function}{$function}{arg_names} = [@arg_names];
        $self->{data}{function}{$function}{arg_types} = [@arg_types];
        $self->{data}{done}{$function} = 1;

        next;

      RESYNC:  # Skip the rest of the current line, and continue.
        $code =~ /\G[^\n]*\n/gc;
    }

   return 1;  # We never fail.
}

1;

__DATA__

=head1 NAME

Inline::C::ParseRegExp - The New and Improved Inline::C Parser

=head1 SYNOPSIS

    use Inline C => DATA =>
               USING => ParseRegExp;

=head1 DESCRIPTION

This module is a much faster version of Inline::C's Parse::RecDescent
parser. It is based on regular expressions instead.

=head2 AUTHOR

Mitchell N Charity <mcharity@vendian.org>

=head1 COPYRIGHT

Copyright (c) 2002. Brian Ingerson.

Copyright (c) 2008, 2010-2012. Sisyphus.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

See http://www.perl.com/perl/misc/Artistic.html

=cut
