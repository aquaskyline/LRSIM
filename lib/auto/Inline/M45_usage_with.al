# NOTE: Derived from blib/lib/Inline.pm.
# Changes made here will be lost when autosplit is run again.
# See AutoSplit.pm.
package Inline;

#line 1852 "blib/lib/Inline.pm (autosplit into blib/lib/auto/Inline/M45_usage_with.al)"
sub M45_usage_with {
    return <<END;
Syntax error detected using 'use Inline with ...'.
Should be specified as:

    use Inline with => 'module1', 'module2', ..., 'moduleN';

END
}

# end of Inline::M45_usage_with
1;
