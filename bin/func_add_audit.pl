use strict;
use warnings;

my $current_file = '';
my $check_next_is_audit = 0;
my @funclines = ();

while (<>) {

    ##
    ## Check for next file
    ##
    if ($ARGV ne $current_file) {
        ## Write out the current file
        if ($current_file) {
            my $oh = IO::File->new("> ${current_file}.bak");
            $oh->print(@funclines, '');
            $oh->close();
        }
        ## Set up for new file
        $current_file = $ARGV;
        $check_next_is_audit=0;
        @funclines = ();
    }

    ##
    ## Look for the opening {
    ##
    m/^{\s*$/ && do {
        $check_next_is_audit=1;
        push @funclines, $_;
        next;
    };

    ##
    ## If we have already audited, just passthough
    ##
    m/## This is audit/ && do {
        $check_next_is_audit=0;
        push @funclines, $_;
        next;
    };

    $check_next_is_audit == 0 && do {
        push @funclines, $_;
        next;
    };

    $check_next_is_audit == 1 && !m/## This is audit/ && do {
        push @funclines,
          qq(    echo "\${FUNCNAME[0]} \\"\$@\\" ## \$(date +%Y%m%d%H%M%S)" >> \${TILDAE:-$HOME}/bloomberg/data/funcsaudit ## This is audit\n),
          $_;
        $check_next_is_audit=0;
        next;
    };

    die "We shouldn't get here:\nfile $current_file, line $. $_";
}

END {
    ## Write out the last funcs file
    if ($current_file) {
        my $oh = IO::File->new("> ${current_file}.bak");
        $oh->print(@funclines, '');
        $oh->close();
    }
}
