package Inline::C::ParseRecDescent;
use strict;
use Carp;

sub register {
    {
     extends => [qw(C)],
     overrides => [qw(get_parser)],
    }
}

sub get_parser {
    my $o = shift;
    Inline::C::_parser_test("Inline::C::ParseRecDescent::get_parser called\n") if $o->{CONFIG}{_TESTING};
    eval { require Parse::RecDescent };
    croak <<END if $@;
This innvocation of Inline requires the Parse::RecDescent module.
$@
END
    $main::RD_HINT++;
    Parse::RecDescent->new(grammar())
}

sub grammar {
    <<'END';

code:   part(s)
        {
         return 1;
        }

part:   comment
      | function_definition
        {
         my $function = $item[1][0];
         $return = 1, last if $thisparser->{data}{done}{$function}++;
         push @{$thisparser->{data}{functions}}, $function;
         $thisparser->{data}{function}{$function}{return_type} =
             $item[1][1];
         $thisparser->{data}{function}{$function}{arg_types} =
             [map {ref $_ ? $_->[0] : '...'} @{$item[1][2]}];
         $thisparser->{data}{function}{$function}{arg_names} =
             [map {ref $_ ? $_->[1] : '...'} @{$item[1][2]}];
        }
      | function_declaration
        {
         $return = 1, last unless $thisparser->{data}{AUTOWRAP};
         my $function = $item[1][0];
         $return = 1, last if $thisparser->{data}{done}{$function}++;
         my $dummy = 'arg1';
         push @{$thisparser->{data}{functions}}, $function;
         $thisparser->{data}{function}{$function}{return_type} =
             $item[1][1];
         $thisparser->{data}{function}{$function}{arg_types} =
             [map {ref $_ ? $_->[0] : '...'} @{$item[1][2]}];
         $thisparser->{data}{function}{$function}{arg_names} =
             [map {ref $_ ? ($_->[1] || $dummy++) : '...'} @{$item[1][2]}];
        }
      | anything_else

comment:
        m{\s* // [^\n]* \n }x
      | m{\s* /\* (?:[^*]+|\*(?!/))* \*/  ([ \t]*)? }x

function_definition:
        rtype IDENTIFIER '(' <leftop: arg ',' arg>(s?) ')' '{'
        {
         [@item[2,1], $item[4]]
        }

function_declaration:
        rtype IDENTIFIER '(' <leftop: arg_decl ',' arg_decl>(s?) ')' ';'
        {
         [@item[2,1], $item[4]]
        }

rtype:  rtype1 | rtype2

rtype1: modifier(s?) TYPE star(s?)
        {
         $return = $item[2];
         $return = join ' ',@{$item[1]},$return
           if @{$item[1]} and $item[1][0] ne 'extern';
         $return .= join '',' ',@{$item[3]} if @{$item[3]};
         return undef unless (defined $thisparser->{data}{typeconv}
                                                   {valid_rtypes}{$return});
        }

rtype2: modifier(s) star(s?)
        {
         $return = join ' ',@{$item[1]};
         $return .= join '',' ',@{$item[2]} if @{$item[2]};
         return undef unless (defined $thisparser->{data}{typeconv}
                                                   {valid_rtypes}{$return});
        }

arg:    type IDENTIFIER {[@item[1,2]]}
      | '...'

arg_decl:
        type IDENTIFIER(s?) {[$item[1], $item[2][0] || '']}
      | '...'

type:   type1 | type2

type1:  modifier(s?) TYPE star(s?)
        {
         $return = $item[2];
         $return = join ' ',@{$item[1]},$return if @{$item[1]};
         $return .= join '',' ',@{$item[3]} if @{$item[3]};
         return undef unless (defined $thisparser->{data}{typeconv}
                                                   {valid_types}{$return});
        }

type2:  modifier(s) star(s?)
        {
         $return = join ' ',@{$item[1]};
         $return .= join '',' ',@{$item[2]} if @{$item[2]};
         return undef unless (defined $thisparser->{data}{typeconv}
                                                   {valid_types}{$return});
        }

modifier:
        'unsigned' | 'long' | 'extern' | 'const'

star:   '*'

IDENTIFIER:
        /\w+/

TYPE:   /\w+/

anything_else:
        /.*/

END
}

my $hack = sub { # Appease -w using Inline::Files
    print Parse::RecDescent::IN '';
    print Parse::RecDescent::IN '';
    print Parse::RecDescent::TRACE_FILE '';
    print Parse::RecDescent::TRACE_FILE '';
};

1;

__DATA__

=head1 NAME

Inline::C::ParseRecDescent - The Classic Inline::C Parser

=head1 SYNOPSIS

    use Inline C => DATA =>
               USING => ParseRecDescent

=head1 DESCRIPTION

This module is Inline::C's original Parse::RecDescent based parser. It
was previously packaged as Inline::C::grammar.

Try Inline::C::ParseRegExp for an alternative.

=head2 AUTHOR

Brian Ingerson <ingy@ttul.org>

=head1 COPYRIGHT

Copyright (c) 2002. Brian Ingerson.

Copyright (c) 2008, 2010, 2011. Sisyphus.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

See http://www.perl.com/perl/misc/Artistic.html

=cut
