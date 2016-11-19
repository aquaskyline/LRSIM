# NOTE: Derived from blib/lib/Inline.pm.
# Changes made here will be lost when autosplit is run again.
# See AutoSplit.pm.
package Inline;

#line 1693 "blib/lib/Inline.pm (autosplit into blib/lib/auto/Inline/M29_error_relative_path.al)"
sub M29_error_relative_path {
    my ($name, $path) = @_;
    return <<END;
Can't load installed extension '$name'
from relative path '$path'.

END
#'
}

# end of Inline::M29_error_relative_path
1;
