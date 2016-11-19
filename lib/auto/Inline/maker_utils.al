# NOTE: Derived from blib/lib/Inline.pm.
# Changes made here will be lost when autosplit is run again.
# See AutoSplit.pm.
package Inline;

#line 1235 "blib/lib/Inline.pm (autosplit into blib/lib/auto/Inline/maker_utils.al)"
#==============================================================================
# Hand off this invokation to Inline::MakeMaker
#==============================================================================
sub maker_utils {
    require Inline::MakeMaker;
    goto &Inline::MakeMaker::utils;
}

# end of Inline::maker_utils
1;
