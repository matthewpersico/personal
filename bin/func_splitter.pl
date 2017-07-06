use strict;
use warnings;

my $current_file = '';
my @oldlines = ();
my $in_func = 0;
my $current_func = '';
my @funclines = ();
my %seen;

while (<>) {

    ##
    ## Check for next file to split
    ##
    if ($ARGV ne $current_file) {

        ## Write out the current file
        if ($current_file) {
            my $oh = IO::File->new("> ${current_file}.bak");
            $oh->print(@oldlines, '');
            $oh->close();
        }

        ## Set up for new file
        $current_file = $ARGV;
        @oldlines = ();
        $in_func = 0;
        $current_func = '';
        @funclines = ();
    }

    ##
    ## Match function first line
    ##
    m/^([a-zA-Z0-9_\+-]+)\s*\(\)/ && !$in_func && do {
        $current_func = $1;
        if ($current_func =~ m/^git_/) {
            die "$current_func needs a _ to - swap.\n";
        } elsif ($current_func =~ m/^git[a-z]/) {
            print "$current_func does not have a '-', must be an alias, skipping.\n";
        } elsif (defined $seen{$func} ) {
            die "Trying to split '$func' out of '$current_file', but we've already split '$func' out of '$seen{$func}->{source}'";
        } else {
            $seen{$func} = {source => $current_file};
            $in_func = 1;
            @funclines = ($_);
        }
        next;
    };

    ##
    ## Look for the opening {
    ##
    if ($in_func) {
        next
          if $_ =~ m/^\s*${current_file}_audit(?:\s+"\$\@\"|\w*)/;

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
              qq(    echo "\${FUNCNAME[0]} \\"\$@\\" ## \$(date +%Y%m%d%H%M%S)" >> \${HOME}/bloomberg/data/funcsaudit ## This is audit\n),
              $_;
            $check_next_is_audit=0;
            next;
        };
    }

    ##
    ## Match function last line
    ##
    m/^}/ && $in_func && do {
        push @funclines, $_;
        my $funclinesstring = join('', @funclines);
        my $oh = IO::File->new("> $current_func");
        $oh->print(<<EOH);
# -*- sh -*-

# <Function Class: $ARGV>

$funclinesstring

EOH
          ; ## make emacs indenting happy
        $oh->close();
        $in_func = 0;
        $current_func = '';
        @funclines = '';
        next;
    };

    $in_func && do {
    };

    push @oldlines, $_
      if !@oldlines or $_ ne $oldlines[-1];
}

END {
    ## Write out the last funcs file
    if ($current_file) {
        my $oh = IO::File->new("> ${current_file}.bak");
        $oh->print(@oldlines, '');
        $oh->close();
    }
}
