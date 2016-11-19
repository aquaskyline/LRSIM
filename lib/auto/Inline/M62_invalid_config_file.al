# NOTE: Derived from blib/lib/Inline.pm.
# Changes made here will be lost when autosplit is run again.
# See AutoSplit.pm.
package Inline;

#line 2004 "blib/lib/Inline.pm (autosplit into blib/lib/auto/Inline/M62_invalid_config_file.al)"
sub M62_invalid_config_file {
    my ($config) = @_;
    return <<END;
You are using a config file that was created by an older version of Inline:

    $config

This file and all the other components in its directory are no longer valid
for this version of Inline. The best thing to do is simply delete all the
contents of the directory and let Inline rebuild everything for you. Inline
will do this automatically when you run your programs.

END
}

# end of Inline::M62_invalid_config_file
1;
