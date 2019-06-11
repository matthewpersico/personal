#!/usr/bin/env perl

use strict;
use warnings;

use File::Basename;

## This only does the physical transform. The complete set of steps for function X is:
##

if ( @ARGV == 0 ) {
    print <<'EOF'

# Issue the following command sequence to convert one or more files X* from
# functions to scripts, assuming that you are working in a directory with two
# subdirectories 'functions' and 'bin' with functions files in the former and
# this script in the latter.

  rm committem     ## a file holding the functions we chose to commit after conversion
  git mv functions/X* bin
  git commit functions/X* -m 'func to exec, mv phase'
  git commit bin/X* -m 'func to exec, mv phase'
  ./bin/func-to-exec.pl bin/X*
  for i in bin/X*
  do
    diff -w $i ${i}.new
    resp=$(yesno "mv ${i}.new $i")
    [ "$resp" = 'y' ] && mv ${i}.new $i" && echo $i >> committem
  done
  git commit $(cat committem) -m 'func to exec, convert phase'

EOF
      ;
    exit 0;
}

my $current_pathfile     = '';
my $current_file         = '';
my $current_file_has_pod = 0;
my @funclines            = ();

my %RE = (
    funcname => qr/[a-zA-Z0-9_\+-]+/,
    lvarname => qr/[a-zA-z_][0-9a-zA-z_]+/,
    rvarname => qr/\$[a-zA-z_][0-9a-zA-z_]+/,
);

my $lineno;
LINE: while (<>) {
    ##
    ## Check for next file to convert.
    ##
    if ( $ARGV ne $current_pathfile ) {
        ## Write out the current file.
        if ($current_pathfile) {
            writeit();
        }
        ## Set up for new file.
        $current_pathfile     = $ARGV;
        $current_file         = basename $ARGV;
        $current_file_has_pod = 0;
        @funclines            = ();
        $lineno               = 0;
        print qq($current_pathfile\n);
    }
    $lineno++;

    ##
    ## Ensure shebang, unwind shellcheck shell spec.
    ##
    if ( $lineno == 1 and $_ !~ m|^#!/usr/bin/env bash| ) {
        ## Line 1 must be a shebang.
        push @funclines, qq(#!/usr/bin/env bash\n);
        next LINE;
    }
    if ( $lineno == 2 && $_ =~ m/shellcheck shell=bash/ ) {
        next LINE;
    }

    ##
    ## Function information confirmed for replacement with current filename.
    ##
    m/# <(?:Function )?Class:/i && do {
        push @funclines, join( qq(\n), qq(# $current_file), '' );
        next LINE;
    };
    m/# <Function Justification:\s+(.*)>/i && do {
        next LINE if $1 =~ m/^none*/;
        die "Function appears to have justification: $1\n";
    };

    ##
    ## Get rid of the @@ stuff now that we use proper POD
    ##
    m/\@\@.*\|\|/ && next LINE;

    ##
    ## The next four function-related sections only work because we are
    ## reasonably fastidious about format of the functions in files.
    ##
    ## funcname ()
    ## {
    ##  .. code goes here..
    ## }
    ##
    ## or
    ##
    ## funcname () {
    ##  .. code goes here..
    ## }
    ##
    ## We used to only accept the first form, but we've come to accept the
    ## second after we found it in some cases.

    ## Matches the function first line (name () {). Throw it away.
    m/^($RE{funcname}) \s*\(\)\s*{\s*$/o && do {
        next LINE;
    };

    ## Matches the function first line (name and ()). Gets the following first
    ## (opening) '{'. Throws both away.
    m/^($RE{funcname})\s*\(\)/o && do {
        my $throwaway = <>;
        $throwaway =~ m/^{\s*$/ && next LINE;
        die "Mismatch: func () found but next line is not {";
    };

    ## Throw away function last (closing) '}'.
    m/^}/ && next LINE;

    ## Remove audit lines.
    m/## This is audit/ && next LINE;

    ##
    ## From here on down go filters that are not mutex. If you write a 'next
    ## LINE' condition below, consider moving it above this comment so as not
    ## to throw away something we spent processor time munging.
    ##

    ## Spacing; remove the first level of indentation from all lines now that
    ## we are not in a function.
    $_ =~ s/^    //;

    ## No locals outside of funcs.
    m/\blocal\b/ && do {
        ## Don't want to change a comment. Not perfect. We could be
        ## pathological and have code like
        ##
        ##       local x; # the local variable
        ##
        ## That's why the calling script does a diff so that we visually
        ## inspect, instead of just doing
        ##    next LINE if $_ =~ m/#.*local/;
        $_ =~ s/(\b)local(\b)/${1}declare${2}/g;
    };

    ## No returns outside of funcs.
    m/\breturn\b/ && do {
        ## See above about comments and pathologicals.
        $_ =~ s/(\b)return(\b)/${1}exit${2}/g
          if $_ !~ m/#.*return|_git-cd-return/;
        ## Don't make the change if return is
        ##    - in a comment
        ##    - part of a function name that uses '-'.\b matches '-',
        ##    but not '_', so that _git_cd_return would never even gotten in
        ##    here, but we have to exception check for _git-cd-return.
    };

    ## *echo -i gets removed
    $_ =~ m/func-echo\s+-i\s/ && next LINE;

    ## func-X becomes script-X...
    $_ =~ s/func-(yesno|pick|usage)/script-$1/g;

    ## ...except that func-echo becomes cmd-echo
    $_ =~ s/func-echo/cmd-echo/g;

    ## usage_func transform
    $_ =~ s/\$usage_func/script-usage/;

    ## SC2155
    ## This regexp really should be in Regexp::Common
    m/^(\s*)(declare\s+)($RE{lvarname})(=.*)/ && do {
        $_ = "${1}${2}${3}\n${1}${3}${4}\n";
    };

    ## SC2086
    m/(\b(?:return|exit)\b)(\s+)(\$(?:OK|NOT_OK))/ && do {
        $_ =~ s/(\b(?:return|exit)\b)(\s+)(\$(?:OK|NOT_OK))/${1}${2}"${3}"/;
    };

    ## Documentation :-)
    $current_file_has_pod = 1
      if $_ =~ m/^:<<'__PODUSAGE__'/;

    ## Fix up the name used to id the program in getopt
    s/(getopt.*)\$\{{0,1}FUNCNAME\[0\]\}/${1}\$0/;

    ## Now that we are here, we want it.
    push @funclines, $_;
}

sub writeit {
    my $oh = IO::File->new("> ${current_pathfile}.tmp");
    if ( !$current_file_has_pod ) {
        push @funclines, <<EOF
## POD guard
exit 0

## You can add sections with =head1, but stick to =item for section breakdowns,
## not =head2/3/etc/.

:<<'__PODUSAGE__'
=head1 NAME

$current_file - script that does something

=head1 SYNOPSIS

 $current_file [--option1] [ --option2 optionarg ] arg1 [arg2 ...] \
     [fee] [dfsdfs] [sfsdfsf]

=head1 DESCRIPTION

Describe in general terms what $current_file does.

=head1 ARGUMENTS

=over 4

=item arg

Describe what arg does, should be, etc. Add a new =item for each distinct arg.

=back

=head1 OPTIONS

=over 4

=item --option1

Describe what --option1 does.

=item --option2

Describe what --option2 does. Describe what optionarg does.

=over 2

=item *

A choice for optionarg

=item *

Another choice for optionarg

=back

=back

=cut

__PODUSAGE__

EOF
    }

    $oh->print( @funclines, '' );
    $oh->close();
}

END {
    ## Write out the last file.
    if ($current_pathfile) {
        writeit();
    }
}
