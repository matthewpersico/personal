package ApplyEverywhereUtils;

use strict;
use warnings;

use Exporter 'import';
our @EXPORT_OK = qw(git_find_perl_code
  code_has_taint_flag
  init_env);

sub git_find_perl_code {
    my %args  = @_;
    my @files = @{ $args{files} };
    if ( !@files ) {
        if ( $args{mod_only} ) {
            ## Tracked and modified.
            @files = qx(git status --porcelain | grep -v '?' | sed 's/.* //');
        } elsif ( $args{nonmod_only} ) {
            ## Tracked and NOT modified.
            my %files = map { chomp; $_ => 1 } qx(git ls-files);
            @files = map { chomp; $_ }
              qx(git status --porcelain | grep -v '?' | sed 's/.* //');
            delete @files{@files};    ## The first @files represents slice of
            ## %files and the second is @files, the list
            ## of keys in the slice. I love Perl but
            ## even I think the syntax is borken.
            @files = keys %files;
        } else {
            ## Tracked.
            @files = qx(git ls-files);
        }
    }
    ## The -f serves two purposes:
    ## 1) We only want to examine files, not directories or links
    ## 2) If you're in the middle of removing files from a repo, but haven't
    ## committed yet, the deleted files will show up in the 'git ls-files'
    ## output.
    @files = grep { -f $_ } map { chomp; $_ } @files;

    ## modules (.pm), scripts (.pl), test files(.t) and .psgi from Catalyst.
    my @byname = grep { $_ =~ m/\.(p[ml]|t|sgi)$/i } @files;

    ## searching for shebang lines because lots of scripts do not
    ## end in .pl
    my @bycontent;
    @bycontent = qx(grep -l '^#!.*perl' @files)
      if (@files);

    ## A .pl with a shebang shows up in both lists.
    my %uniq = map { chomp; $_ => 1 } ( @byname, @bycontent );

    return sort keys %uniq;
}

sub code_has_taint_flag {
    open( OH, '<', $_[0] )
      or die "Cannot read $_[0]";

    my $head = <OH>;

    my $ret = ( $head =~ m/#!.*perl.*-w*T/ );

    return $ret;
}

## This can be modifed per repo/project as needed
sub init_env {
    $ENV{DPKG_DISTROCTL_DISTRIBUTION} = q(anything);
    $ENV{DPKG_DISTROCTL_REALUSER}     = q(anything);
    $ENV{DPKG_DISTRO_DEV_ROOT}        = q(/tmp);
}

1;
