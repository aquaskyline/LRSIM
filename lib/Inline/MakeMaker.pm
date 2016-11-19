package Inline::MakeMaker;

$Inline::MakeMaker::VERSION = '0.53';
$Inline::MakeMaker::VERSION = eval $Inline::MakeMaker::VERSION;
@EXPORT = qw(WriteMakefile WriteInlineMakefile);

use strict;
use base 'Exporter';
use ExtUtils::MakeMaker();
use Carp;

sub WriteInlineMakefile {
#    warn <<END;
#
#Inline::MakeMaker::WriteInlineMakefile() is deprecated as of Inline-0.44.
#Inline::MakeMaker::WriteMakefile() should be used instead.
#
#END
    goto &WriteMakefile;
}

sub WriteMakefile {
    my %args = @_;
    my $name = $args{NAME}
      or croak "Inline::MakeMaker::WriteMakefile requires the NAME parameter\n";
    my $object = (split(/::/, $name))[-1];
    my $version = '';

    croak <<END unless (defined $args{VERSION} or defined $args{VERSION_FROM});
Inline::MakeMaker::WriteMakefile requires either the VERSION or VERSION_FROM
parameter.
END
    if (defined $args{VERSION}) {
        $version = $args{VERSION};
    }
    else {
        $version = ExtUtils::MM_Unix->parse_version($args{VERSION_FROM})
          or croak "Can't determine version for $name\n";
    }
    croak <<END unless $version =~ /^\d\.\d\d$/;
Invalid version '$version' for $name.
Must be of the form '#.##'. (For instance '1.23')
END

    # Provide a convenience rule to clean up Inline's messes
    $args{clean} = { FILES => "_Inline $object.inl" }
    unless defined $args{clean};
    # Add Inline to the dependencies
    $args{PREREQ_PM}{Inline} = '0.44' unless defined $args{PREREQ_PM}{Inline};

    &ExtUtils::MakeMaker::WriteMakefile(%args);

    open MAKEFILE, '>> Makefile'
      or croak "Inline::MakeMaker::WriteMakefile can't append to Makefile:\n$!";

    print MAKEFILE <<MAKEFILE;
# Well, not quite. Inline::MakeMaker is adding this:

# --- MakeMaker inline section:

$object.inl : \$(TO_INST_PM)
	\$(PERL) -Mblib -MInline=NOISY,_INSTALL_ -M$name -e1 $version \$(INST_ARCHLIB)

pure_all :: $object.inl

# The End is here.
MAKEFILE

    close MAKEFILE;
}

1;
