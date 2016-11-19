# NOTE: Derived from blib/lib/Inline.pm.
# Changes made here will be lost when autosplit is run again.
# See AutoSplit.pm.
package Inline;

#line 873 "blib/lib/Inline.pm (autosplit into blib/lib/auto/Inline/check_module.al)"
#==============================================================================
# Check to see if code has already been compiled
#==============================================================================
sub check_module {
    my ($module, $module2);
    my $o = shift;
    return $o->install if $o->{CONFIG}{_INSTALL_};

    if ($o->{CONFIG}{NAME}) {
	$module = $o->{CONFIG}{NAME};
    }
    elsif ($o->{API}{pkg} eq 'main') {
	$module = $o->{API}{script};
        my($v,$d,$file) = File::Spec->splitpath($module);
        $module = $file;
	$module =~ s|\W|_|g;
	$module =~ s|^_+||;
	$module =~ s|_+$||;
	$module = 'FOO' if $module =~ /^_*$/;
	$module = "_$module" if $module =~ /^\d/;
    }
    else {
	$module = $o->{API}{pkg};
    }

    $o->{API}{suffix} = $o->{INLINE}{ILSM_suffix};
    $o->{API}{directory} = $o->{INLINE}{DIRECTORY};

    my $auto_level = 2;
    while ($auto_level <= 5) {
	if ($o->{CONFIG}{AUTONAME}) {
	    $module2 =
	      $module . '_' . substr($o->{INLINE}{md5}, 0, 2 + $auto_level);
	    $auto_level++;
	} else {
	    $module2 = $module;
	    $auto_level = 6; # Don't loop on non-autoname objects
	}
	$o->{API}{module} = $module2;
	my @modparts = split /::/, $module2;
	$o->{API}{modfname} = $modparts[-1];
        $o->{API}{modpname} = File::Spec->catdir(@modparts);
	$o->{API}{build_dir} =
          File::Spec->catdir($o->{INLINE}{DIRECTORY},
                             'build',$o->{API}{modpname});
        $o->{API}{install_lib} =
          File::Spec->catdir($o->{INLINE}{DIRECTORY}, 'lib');

        my $inl = File::Spec->catfile($o->{API}{install_lib},"auto",
                          $o->{API}{modpname},"$o->{API}{modfname}.inl");
        $o->{API}{location} =
          File::Spec->catfile($o->{API}{install_lib},"auto",$o->{API}{modpname},
                              "$o->{API}{modfname}.$o->{INLINE}{ILSM_suffix}");
	last unless -f $inl;
	my %inl;
	{   local ($/, *INL);
	    open INL, $inl or croak M31_inline_open_failed($inl);
	    %inl = Inline::denter->new()->undent(<INL>);
	}
	next unless ($o->{INLINE}{md5} eq $inl{md5});
	next unless ($inl{inline_version} ge '0.40');
      next unless ($inl{Config}{version} eq $Config::Config{version});
      next unless ($inl{Config}{archname} eq $Config::Config{archname});
	unless (-f $o->{API}{location}) {
	    warn <<END if $^W;
Missing object file: $o->{API}{location}
For Inline file: $inl
END
	    next;
	}
	$o->{INLINE}{object_ready} = 1 unless $o->{CONFIG}{FORCE_BUILD};
	last;
    }
    unshift @::INC, $o->{API}{install_lib};
}

# end of Inline::check_module
1;
