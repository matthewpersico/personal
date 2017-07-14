use strict;
use warnings;

my $current_file = '';
my @funclines = ();

sub writeit {
    my $oh = IO::File->new("> ${current_file}.bak");
    $oh->print(@funclines, '');
    $oh->close();
}

while (<>) {

    ##
    ## Check for next file to convert
    ##
    if ($ARGV ne $current_file) {
        ## Write out the current file
        if ($current_file) {
            writeit();
        }
        ## Set up for new file
        $current_file = $ARGV;
        @funclines = ();
        print qq($current_file\n);
    }

    ## Shebang insertion
    m/# -\*- sh -\*-/ &&do {
        push @funclines, qq(#!/usr/bin/env bash\n);
        next;
    };

    ## Function class replacement
    m/# <Function Class:/ && do {
        push @funclines, qq(# $current_file\n);
        next;
    };

    ## Throw away function first line and first '{'
    m/^([a-zA-Z0-9_\+-]+)\s*\(\)/ && do {
        my $throwaway = <>;
        next;
    };

    ## Throw away function last '}'
    m/^}/ && next;

    ## Spacing
    $_ =~ s/^    //;

    ## Fix the audit line
    m/## This is audit/ && do {
        $_ =~ s/funcsaudit/binaudit/;
        $_ =~ s/\$\{FUNCNAME\[0\]\}/$current_file/;
        push @funclines, $_;
        next;
    };

    ## No push between these two - they could be on the same line

    ## No locals outside of funcs
    m/\blocal\b/ && do {
        $_ =~ s/(\b)local(\b)/${1}declare${2}/;
    };

    ## No returns outside of funcs
    m/\breturn\b/ && do {
        $_ =~ s/(\b)return(\b)/${1}exit${2}/;
    };

    push @funclines, $_;
    next;

}

END {
    ## Write out the last file
    if ($current_file) {
        writeit();
    }
}
