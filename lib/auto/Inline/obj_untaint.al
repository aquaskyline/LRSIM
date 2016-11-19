# NOTE: Derived from blib/lib/Inline.pm.
# Changes made here will be lost when autosplit is run again.
# See AutoSplit.pm.
package Inline;

#line 1071 "blib/lib/Inline.pm (autosplit into blib/lib/auto/Inline/obj_untaint.al)"
#==============================================================================
# Blindly untaint tainted fields in Inline object.
#==============================================================================
sub obj_untaint {
    my $o = shift;
    warn "In Inline::obj_untaint() : Blindly untainting tainted fields in Inline object.\n" unless $o->{CONFIG}{NO_UNTAINT_WARN};
    ($o->{INLINE}{ILSM_module}) = $o->{INLINE}{ILSM_module} =~ /(.*)/;
    ($o->{API}{build_dir}) = $o->{API}{build_dir} =~ /(.*)/;
    ($o->{CONFIG}{DIRECTORY}) = $o->{CONFIG}{DIRECTORY} =~ /(.*)/;
    ($o->{API}{install_lib}) = $o->{API}{install_lib} =~ /(.*)/;
    ($o->{API}{modpname}) = $o->{API}{modpname} =~ /(.*)/;
    ($o->{API}{modfname}) = $o->{API}{modfname} =~ /(.*)/;
    ($o->{API}{language}) = $o->{API}{language} =~ /(.*)/;
    ($o->{API}{pkg}) = $o->{API}{pkg} =~ /(.*)/;
    ($o->{API}{module}) = $o->{API}{module} =~ /(.*)/;
}

# end of Inline::obj_untaint
1;
