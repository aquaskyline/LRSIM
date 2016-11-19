# NOTE: Derived from blib/lib/Inline.pm.
# Changes made here will be lost when autosplit is run again.
# See AutoSplit.pm.
package Inline;

#line 671 "blib/lib/Inline.pm (autosplit into blib/lib/auto/Inline/read_inline_file.al)"
#==============================================================================
# Get the source code from an Inline::Files filehandle
#==============================================================================
sub read_inline_file {
    my $o = shift;
    my ($lang, $pkg) = @{$o->{API}}{qw(language_id pkg)};
    my $langfile = uc($lang);
    croak M59_bad_inline_file($lang) unless $langfile =~ /^[A-Z]\w*$/;
    croak M60_no_inline_files()
      unless (defined $INC{File::Spec::Unix->catfile("Inline","Files.pm")} and
	      $Inline::Files::VERSION =~ /^\d\.\d\d$/ and
	      $Inline::Files::VERSION ge '0.51');
    croak M61_not_parsed() unless $lang = Inline::Files::get_filename($pkg);
    {
	no strict 'refs';
	local $/;
	$Inline::FILE = \*{"${pkg}::$langfile"};
#	open $Inline::FILE;
	$o->{API}{code} = <$Inline::FILE>;
#	close $Inline::FILE;
    }
}

# end of Inline::read_inline_file
1;
