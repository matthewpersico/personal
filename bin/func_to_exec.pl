#!/usr/bin/env perl

use strict;
use warnings;

use File::Basename;

## This only does the physical transform. The complete set of steps for function X is:
##

if (@ARGV==0) {
    print <<'EOF'

# Issue the following command sequence to convert one or more files X* from
# functions to scripts, assuming that you are working in a directory with two
# subdirectories 'functions' and 'bin' with functions files in the former and
# this script in the latter.

  rm committem     ## a file holding the functions we chose to commit after conversion
  git mv functions/X* bin
  git commit functions/X* -m 'func to exec, mv phase'
  git commit bin/X* -m 'func to exec, mv phase'
  ./bin/func_to_exec.pl bin/X*
  for i in bin/X*
  do
    diff -w $i ${i}.new
    resp=$(yesno "mv ${i}.new $i")
    [ "$resp" = 'y' ] && mv ${i}.new $i") && echo $i >> committem
  done
  git commit $(cat committem) -m 'func to exec, convert phase'

EOF
;
      exit 0;
}

my $current_pathfile = '';
my $current_file = '';
my @funclines = ();

sub writeit {
    my $oh = IO::File->new("> ${current_pathfile}.new");
    $oh->print(@funclines, '');
    $oh->close();
}

while (<>) {
    ##
    ## Check for next file to convert.
    ##
    if ($ARGV ne $current_pathfile) {
        ## Write out the current file.
        if ($current_pathfile) {
            writeit();
        }
        ## Set up for new file.
        $current_pathfile = $ARGV;
        $current_file = basename $ARGV;
        @funclines = ();
        print qq($current_pathfile\n);
    }

    ## Function class replaced with current filename.
    m/# <(?:Function )?Class:/i && do {
        push @funclines, qq(# $current_file\n);
        next;
    };

    m/# <Function Justification.*None>/i && do {
        next;
    };

    ## The next three function-related sections only work because we are
    ## fastidious about format of the functions in files. Format MUST BE:
    ##
    ## funcname ()
    ## {
    ##  .. code goes here..
    ## }
    ##
    ## In particular the function open and close braces must be on their own
    ## lines.

    ## Matches the function first line (its name and ()). Gets the following
    ## first '{'. Throws both away.
    m/^([a-zA-Z0-9_\+-]+)\s*\(\)/ && do {
        my $throwaway = <>;
        next;
    };

    ## Throw away function last '}'.
    ## format.
    m/^}/ && next;

    ## Spacing; remove the first level of indentation from all lines now that
    ## we are not in a function.
    $_ =~ s/^    //;

    ## Remove audit lines.
    m/## This is audit/ && do {
        $_ =~ s/funcsaudit/binaudit/;
        $_ =~ s/\$\{FUNCNAME\[0\]\}/$current_pathfile/;
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
        ## That's why we diff and visually inspect instead of trying
        ##    next if $_ =~ m/#.*local/;
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
    if ($current_pathfile) {
        writeit();
    }
}
