package PerlBulkUtils;

use 5.16.3;
use warnings;

use Exporter 'import';
our @EXPORT_OK = qw(
  code_has_taint_flag
  get_files
  is_git_repo
  message
  process_eval_file
  process_exclusions
);

use File::Spec::Functions qw(
  catfile
  splitdir
);
use List::MoreUtils qw(uniq);
use Test::More;

sub code_has_taint_flag {
    open( OH, '<', $_[0] )
      or die "Cannot read $_[0]";

    my $head = <OH>;

    my $ret = ( $head =~ m/#!.*perl.*-w*T/ );

    return $ret;
}

sub filter {
    ## The -f serves two purposes:
    ## 1) We only want to examine files, not directories or links.
    ## 2) If you're in the middle of removing files from a repo, but haven't
    ## committed yet, the deleted files will show up in the 'git ls-files'
    ## output, so we want to NOT process those.
    my @files = grep { -f $_ } map { chomp; $_ } uniq(@_);

    if (@files) {
        ## modules (.pm), scripts (.pl), test files(.t) and .psgi from Catalyst.
        my @byname = grep { $_ =~ m/\.(p[ml]|t|sgi)$/i } @files;

        ## searching for shebang lines because lots of scripts do not
        ## end in .pl
        my @bycontent = qx(grep -l '^#!.*perl' @files);

        ## A .pl with a shebang shows up in both lists.
        return sort uniq( map { chomp; $_ } ( @byname, @bycontent ) );
    }
    return ();
}

sub find_perl_code {
    my @files;

    for (@_) {
        if ( -d $_ ) {
            push @files, qx(find $_ -type f);
        } elsif ( -f _ ) {
            push @files, $_;
        } else {
            warn "$_ is not a file or a directory; skipping...\n";
        }
    }
    return @files ? filter(@files) : ();
}

sub get_files {
    my %opt = (
        all       => 0,
        mod       => 0,
        untracked => 0,
        @_
    );

    my @files;
    my @msg;
    if (@ARGV) {
        @files = find_perl_code(@ARGV);
        if ( !@files ) {
            push @msg, "No files found for arguments given.\n";
        }
    } else {
        if ( !is_git_repo() ) {
            push @msg,
              "No arguments given and current directory is not a git repo.\n";
        } else {
            @files = git_find_perl_code(
                all       => $opt{all},
                mod       => $opt{mod},
                untracked => $opt{untracked}
            );
            if ( !@files ) {
                push @msg, "No Perl files found in git repo";
                my @opts;
                for (qw (mod untracked all )) {
                    push @opts, "--$_" if $opt{$_};
                }
                if ( @opts == 0 ) {
                    $msg[0] .= '.';
                } elsif ( @opts == 1 ) {
                    push @msg, "to match option '@opts'.";
                } elsif ( @opts > 1 ) {
                    push @msg, "to match options", @opts;
                }
            }
        }
    }
    die join( qq(\n), @msg, '' )
      if @msg;
    return @files;
}

sub git_find_perl_code {
    my %args = @_;
    my @files;
    my $opts_set = 0;

    if ( $args{mod} ) {
        ## Tracked files that are modified.
        push @files, qx(git status --porcelain | grep -v '?' | sed 's/.* //');
        $opts_set++;
    }
    if ( $args{untracked} or $args{all} ) {
        ## Untracked files.
        push @files, qx(git status --porcelain | grep '?' | sed 's/.* //');
        $opts_set++;
    }
    if ( $args{all} or not $opts_set ) {
        ## Tracked files, modified or not.
        push @files, qx(git ls-files);
    }
    return @files ? filter(@files) : ();
}

sub is_git_repo {
    my $location = '';
    if ( $_[0] ) {
        $location = "-C $_[0]";
    }
    qx(git $location rev-parse --show-toplevel 2>/dev/null 1>&2);
    return $? ? 0 : 1;
}

sub message {
    my %args = (
        testing => 0,
        func    => undef,
        output  => [],
        @_
    );

    if ( $args{testing} and $args{func} =~ m/pass|fail|diag/ ) {
        no strict 'refs';
        $args{func}->( @{ $args{output} } );
    } else {
        print STDERR @{ $args{output} };
    }
}

sub process_eval_file {
    my $eval_file = $_[0];
    my @path      = splitdir( $ENV{PWD} );
    my $eval_file_resolved;
  SEARCH: while (@path) {
        my $spec = catfile( @path, $eval_file );
        if ( -f $spec ) {
            $eval_file_resolved = $spec;
            last SEARCH;
        }
        pop @path;
    }

    if ($eval_file_resolved) {
        my $ih   = IO::File->new( $eval_file_resolved, 'r' );
        my $data = join( '', <$ih> );
        ## Sets some 'our' data structure(s)
        eval $data
          or die "$@";
    }
}

sub process_exclusions {
    my $exclusion_file = $_[0];
    shift;

    ## "our" so we can eval the excludes file into it in
    ## process_eval_file()
    our %excludes;
    process_eval_file($exclusion_file);

    my @includes;
    if ( !keys %excludes ) {
        return @_;
    }

    for my $file (@_) {
        my @excludes;
        for my $exclude_type ( keys(%excludes) ) {
            if ( $exclude_type =~ /grep|contents/ ) {
                my @output;
                for my $excl_pat ( @{ $excludes{'grep'} } ) {
                    my $ih = IO::File->new( $file, 'r' );
                    push @output, grep { m/$excl_pat/ } <$ih>;
                }
                push @excludes, "By contents:\n", @output if (@output);
            } elsif ( $exclude_type eq 'name' ) {
                my @output;
                for my $excl_name ( @{ $excludes{'name'} } ) {
                    push @output, $file if $file =~ m/$excl_name/;
                }
                push @excludes, "By name:\n", join( qq(\n), @output, '' )
                  if (@output);
            } else {
                die "exclude type $exclude_type has no processing steps.\n";
            }
        }

        if (@excludes) {
            warn "$file is excluded from tidying for the following reasons:\n",
              @excludes;
        } else {
            push @includes, $file;
        }
    }
    return @includes;
}

1;
