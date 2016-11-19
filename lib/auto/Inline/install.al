# NOTE: Derived from blib/lib/Inline.pm.
# Changes made here will be lost when autosplit is run again.
# See AutoSplit.pm.
package Inline;

#line 949 "blib/lib/Inline.pm (autosplit into blib/lib/auto/Inline/install.al)"
#==============================================================================
# Set things up so that the extension gets installed into the blib/arch.
# Then 'make install' will do the right thing.
#==============================================================================
sub install {
    my ($module, $DIRECTORY);
    my $o = shift;

    croak M64_install_not_c($o->{API}{language_id})
      unless uc($o->{API}{language_id}) =~ /^(C|CPP|Java|Python|Ruby|Lisp|Pdlpp)$/ ;
    croak M36_usage_install_main()
      if ($o->{API}{pkg} eq 'main');
    croak M37_usage_install_auto()
      if $o->{CONFIG}{AUTONAME};
    croak M38_usage_install_name()
      unless $o->{CONFIG}{NAME};
    croak M39_usage_install_version()
      unless $o->{CONFIG}{VERSION};
    croak M40_usage_install_badname($o->{CONFIG}{NAME}, $o->{API}{pkg})
      unless $o->{CONFIG}{NAME} eq $o->{API}{pkg};
#	      $o->{CONFIG}{NAME} =~ /^$o->{API}{pkg}::\w(\w|::)+$/
#	     );

    my ($mod_name, $mod_ver, $ext_name, $ext_ver) =
      ($o->{API}{pkg}, $ARGV[0], @{$o->{CONFIG}}{qw(NAME VERSION)});
    croak M41_usage_install_version_mismatch($mod_name, $mod_ver,
					     $ext_name, $ext_ver)
      unless ($mod_ver eq $ext_ver);
    $o->{INLINE}{INST_ARCHLIB} = $ARGV[1];

    $o->{API}{version} = $o->{CONFIG}{VERSION};
    $o->{API}{module} = $o->{CONFIG}{NAME};
    my @modparts = split(/::/,$o->{API}{module});
    $o->{API}{modfname} = $modparts[-1];
    $o->{API}{modpname} = File::Spec->catdir(@modparts);
    $o->{API}{suffix} = $o->{INLINE}{ILSM_suffix};
    $o->{API}{build_dir} = File::Spec->catdir($o->{INLINE}{DIRECTORY},'build',
                                              $o->{API}{modpname});
    $o->{API}{directory} = $o->{INLINE}{DIRECTORY};
    my $cwd = Cwd::cwd();
    $o->{API}{install_lib} =
      File::Spec->catdir($cwd,$o->{INLINE}{INST_ARCHLIB});
    $o->{API}{location} =
      File::Spec->catfile($o->{API}{install_lib},"auto",$o->{API}{modpname},
                          "$o->{API}{modfname}.$o->{INLINE}{ILSM_suffix}");
    unshift @::INC, $o->{API}{install_lib};
    $o->{INLINE}{object_ready} = 0;
}

# end of Inline::install
1;
