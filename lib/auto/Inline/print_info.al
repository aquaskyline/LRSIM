# NOTE: Derived from blib/lib/Inline.pm.
# Changes made here will be lost when autosplit is run again.
# See AutoSplit.pm.
package Inline;

#line 1186 "blib/lib/Inline.pm (autosplit into blib/lib/auto/Inline/print_info.al)"
#==============================================================================
# Print a small report if PRINT_INFO option is set.
#==============================================================================
sub print_info {
    use strict;
    my $o = shift;

    print STDERR <<END;
<-----------------------Information Section----------------------------------->

Information about the processing of your Inline $o->{API}{language_id} code:

END

    print STDERR <<END if ($o->{INLINE}{object_ready});
Your module is already compiled. It is located at:
$o->{API}{location}

END

    print STDERR <<END if ($o->{INLINE}{object_ready} and $o->{CONFIG}{FORCE_BUILD});
But the FORCE_BUILD option is set, so your code will be recompiled.
I\'ll use this build directory:
$o->{API}{build_dir}

and I\'ll install the executable as:
$o->{API}{location}

END
    print STDERR <<END if (not $o->{INLINE}{object_ready});
Your source code needs to be compiled. I\'ll use this build directory:
$o->{API}{build_dir}

and I\'ll install the executable as:
$o->{API}{location}

END

    eval {
	print STDERR $o->info;
    };
    print $@ if $@;

    print STDERR <<END;

<-----------------------End of Information Section---------------------------->
END
}

# end of Inline::print_info
1;
