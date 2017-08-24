use strict;
use warnings;

## This only does the physical transform. The complete set of steps for function X is:
##
## $ git mv functions/X bin/X
## $ git commit bin/X -m 'func to exec, mv phase'
## $ ./func_to_exec.pl bin/X
## $ diff -w bin/X bin/X.new
## $ mv bin/X.new bin/X
## $ git commit bin/X -m 'func to exec, convert phase'

my $current_file = '';
my @funclines = ();

sub writeit {
    my $oh = IO::File->new("> ${current_file}.new");
    $oh->print(@funclines, '');
    $oh->close();
}

while (<>) {
    ##
    ## Check for next file to convert.
    ##
    if ($ARGV ne $current_file) {
        ## Write out the current file.
        if ($current_file) {
            writeit();
        }
        ## Set up for new file.
        $current_file = $ARGV;
        @funclines = ();
        print qq($current_file\n);
    }

    ## Shebang insertion.
    m/# -\*- sh -\*-/ &&do {
        push @funclines, qq(#!/usr/bin/env bash\n);
        next;
    };

    ## Function class replacement.
    m/# <Function Class:/ && do {
        push @funclines, qq(# $current_file\n);
        next;
    };

    m/# <Class:/ && do {
        push @funclines, qq(# $current_file\n);
        next;
    };

    m/# <Function Justification.*None>/ && do {
        next;
    };

    ## Throw away function first line and first '{'. Only because we are
    ## fastidious about format.
    m/^([a-zA-Z0-9_\+-]+)\s*\(\)/ && do {
        my $throwaway = <>;
        next;
    };

    ## Throw away function last '}'. Only because we are fastidious about
    ## format.
    m/^}/ && next;

    ## Spacing; remove the first level of indentation from all lines now that
    ## we are not in a function. Only because we are fastidious about format.
    $_ =~ s/^    //;

    ## Fix the audit line.
    m/## This is audit/ && do {
        $_ =~ s/funcsaudit/binaudit/;
        $_ =~ s/\$\{FUNCNAME\[0\]\}/$current_file/;
        push @funclines, $_;
        next;
    };

    ## No push between these two - they could be on the same line. Also, make
    ## sure that we did not convert a comment.

    ## No locals outside of funcs.
    m/\blocal\b/ && do {
        ## Don't want to change a comment. Not perfect. We could be
        ## pathological and have code like
        ##
        ##       local x; # the local variable
        ##
        ## That's why we diff and visually inspect next if $_ =~ m/#.*local/;
        $_ =~ s/(\b)local(\b)/${1}declare${2}/g;
    };

    ## No returns outside of funcs.
    m/\breturn\b/ && do {
        next if $_ =~ m/#.*return/; ## See above about comments and
                                    ## pathologicals.
        $_ =~ s/(\b)return(\b)/${1}exit${2}/g;
    };

    ## If we get here, we want it.
    push @funclines, $_;
}

END {
    ## Write out the last file.
    if ($current_file) {
        writeit();
    }
}
