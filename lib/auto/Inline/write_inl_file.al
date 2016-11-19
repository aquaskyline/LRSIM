# NOTE: Derived from blib/lib/Inline.pm.
# Changes made here will be lost when autosplit is run again.
# See AutoSplit.pm.
package Inline;

#line 998 "blib/lib/Inline.pm (autosplit into blib/lib/auto/Inline/write_inl_file.al)"
#==============================================================================
# Create the .inl file for an object
#==============================================================================
sub write_inl_file {
    my $o = shift;
    my $inl =
      File::Spec->catfile($o->{API}{install_lib},"auto",$o->{API}{modpname},
                          "$o->{API}{modfname}.inl");
    open INL, "> $inl"
      or croak "Can't create Inline validation file $inl: $!";
    my $apiversion = $Config{apiversion} || $Config{xs_apiversion};
    print INL Inline::denter->new()
      ->indent(*md5, $o->{INLINE}{md5},
	       *name, $o->{API}{module},
	       *version, $o->{CONFIG}{VERSION},
	       *language, $o->{API}{language},
	       *language_id, $o->{API}{language_id},
	       *installed, $o->{CONFIG}{_INSTALL_},
	       *date_compiled, scalar localtime,
	       *inline_version, $Inline::VERSION,
	       *ILSM, { map {($_, $o->{INLINE}{"ILSM_$_"})}
			(qw( module suffix type ))
		      },
	       *Config, { (map {($_,$Config{$_})}
			   (qw( archname osname osvers
				cc ccflags ld so version
			      ))),
			  (apiversion => $apiversion),
			},
	      );
    close INL;
}

# end of Inline::write_inl_file
1;
