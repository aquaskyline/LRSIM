# NOTE: Derived from blib/lib/Inline/denter.pm.
# Changes made here will be lost when autosplit is run again.
# See AutoSplit.pm.
package Inline::denter;

#line 355 "blib/lib/Inline/denter.pm (autosplit into blib/lib/auto/Inline/denter/M01_invalid_indent_width.al)"
# Undent error messages
sub M01_invalid_indent_width {
    my $o = shift;
    "Invalid indent width detected at line $o->{line}\n";
}

# end of Inline::denter::M01_invalid_indent_width
1;
