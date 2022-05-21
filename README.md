# README

All my UNIX goodies including dotfiles so I can put them on any machine.

## Initial Setup

There are two items to read:

* If you simply want to sync your local environment with the GitHub repo
  directly, read [README-direct](README-direct.md).
* If you need to make a local GHE repo the primary source and sync that with
  the GitHub repo, then read [README-GHE](README-GHE.md) instead.

## Post Setup

### autoloading

One thing that you'll see when you log in is a list of functions that are being
loaded:

```
--- loaded alarm
--- loaded apush
--- loaded aunshift
--- loaded autoloaded-personal
--- loaded cdplus
--- loaded ecd
--- loaded editor_opt
--- loaded github_clone
...
```

These are functions that are being loaded when called by their shims or being
unshimmed. Initially, you will see a lot of them while the profile is run. What
you do not want to see is the same loads being executed over and over again as
you type commands or in the logs of cron jobs.

If you do see this behavior, that means that the function is being loaded over
and over from its file via its shim because the expansion of the
shim is occurring in a subshell and is not being propagated to other
subshells.

In these cases, you don't want to shim the function when loaded via `autoload`
in your profile; you want it expanded, or 'unshimmed' so that it is available
in subshells, even though you may not have expanded it in your main shell. In
order to do this, add the name of each function you want to unshim to a
separate line in the file `$HOME/.config/autoload-unshim.config`.

Once you see no more such items, you can shut off the messages during profile
loading by setting and exporting `AUTOLOAD_TRACK` in
`$HOME/.config/autotrack.config`, which is read by `autoload` when it is
sourced in a profile. Set `AUTOLOAD_TRACK` to one of the following values:

* all - Track every function load.
* :cron: - Only track in cron jobs.
* :noncron: - Only track in non-cron jobs.
* :noprofile: - Only track after .profile is run.
* none - Do not track in anything.

The default, if `$HOME/.config/autoload-config.dat` is not found, is `all`, so
that in a new environment, you can see what's happening.

### Perl modules

Many of the utilities in this repo either use Perl or are Perl. Make sure these
modules are installed:

* File::Slurp
* Lingua::EN::Inflect
* Term::ReadLine::Gnu
* Tk
* Devel::ptkdb

### rsync-backups

Used primarily in an Enterprise situation, this is what needs to be set up for
`rsync-backup`:

```
mkdir -p $HOME/rsync-backup/logs
mkdir -p $HOME/rsync-backup/config
ln -s /The/root/of/the/rsync/backup/target $HOME/rsync-backup/data
```

See the `rsync-backup*` files for more details.
