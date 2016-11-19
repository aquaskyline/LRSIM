# NOTE: Derived from blib/lib/Inline.pm.
# Changes made here will be lost when autosplit is run again.
# See AutoSplit.pm.
package Inline;

#line 1128 "blib/lib/Inline.pm (autosplit into blib/lib/auto/Inline/reportbug.al)"
#==============================================================================
# User wants to report a bug
#==============================================================================
sub reportbug {
    use strict;
    my $o = shift;
    return if $o->{INLINE}{reportbug_handled}++;
    print STDERR <<END;
<-----------------------REPORTBUG Section------------------------------------->

REPORTBUG mode in effect.

Your Inline $o->{API}{language_id} code will be processed in the build directory:

  $o->{API}{build_dir}

A perl-readable bug report including your perl configuration and run-time
diagnostics will also be generated in the build directory.

When the program finishes please bundle up the above build directory with:

  tar czf Inline.REPORTBUG.tar.gz $o->{API}{build_dir}

and send "Inline.REPORTBUG.tar.gz" as an email attachment to the author
of the offending Inline::* module with the subject line:

  REPORTBUG: Inline.pm

Include in the email, a description of the problem and anything else that
you think might be helpful. Patches are welcome! :-\)

<-----------------------End of REPORTBUG Section------------------------------>
END
    my %versions;
    {
	no strict 'refs';
	%versions = map {eval "use $_();"; ($_, $ {$_ . '::VERSION'})}
	qw (Digest::MD5 Parse::RecDescent
	    ExtUtils::MakeMaker File::Path FindBin
	    Inline
	   );
    }

    $o->mkpath($o->{API}{build_dir});
    open REPORTBUG, "> ".File::Spec->catfile($o->{API}{build_dir},"REPORTBUG")
      or croak M24_open_for_output_failed
               (File::Spec->catfile($o->{API}{build_dir},"REPORTBUG"));
    %Inline::REPORTBUG_Inline_Object = ();
    %Inline::REPORTBUG_Perl_Config = ();
    %Inline::REPORTBUG_Module_Versions = ();
    print REPORTBUG Inline::denter->new()
      ->indent(*REPORTBUG_Inline_Object, $o,
	       *REPORTBUG_Perl_Config, \%Config::Config,
	       *REPORTBUG_Module_Versions, \%versions,
	      );
    close REPORTBUG;
}

# end of Inline::reportbug
1;
