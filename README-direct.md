# README-direct
Use these instructions when you can set up the local code to directly talk to
GitHub.

# Setup

## Grab the repos
There are two - one for git templates and the personal repo with all the code.
We assume that you can reach the remote specified. Make sure you have your
'id_rsa' key and your ssh config set up to reach the server.

```
$ GH_REMOTE_REF=github:matthewpersico # or change as needed
$ cd $HOME
$ git clone ${GH_REMOTE_REF}/git_template .git_template
$ vi ~/.gitconfig
    i[init]
    <TAB>templatedir = <EXPAND THE VALUE OF $HOME HERE>/.git_template
    :wq
$ git clone ${GH_REMOTE_REF}/personal
```

## Set up the branches
In each repo, you now have two choices:

### Make a machine-specific branch
If the hostname is unique, `branchname=$(hostname)` should be sufficient. If
not, try `branchname=$(hostname)-$(uname -s)`. When you have a branch name,
execute

```
for i in '.git_template' 'personal'; do
    cd ${HOME}/$i
    git checkout -b $branchname
    git push --set-upstream origin $branchname
done
```

### Use an existing branch name
If you are resetting an existing setup where the branch already exists:
```
for i in '.git_template' 'personal'; do
    cd ${HOME}/$i
    git checkout --track origin/EXISTING-BRANCH-NAME
done
```

Either way, we will refer to this branch as `mach-branch` later on.

## Set up dotfiles
This step stores existing dotfiles and links to new ones in the repo.

```
$ cd $HOME/personal/dotfiles
$ . ./dotfilesbootstrap
$ cd ..
$ bin/makesymlinks -i dotfiles
```
## Test
Before ending the existing terminal session, start up another one and make sure
that all the dotfile links are in place and everything works.

# Keeping things in sync

* Create pull requests on GitHub from `mach-branch` into `main`.  Resolve the
  PR via a `Rebase`; you can do this with the GUI. Do not do a `Squash and
  merge` or a `Merge` into `main` via the GUI. Those actions will create
  cluttering Merge commit entries.
* Make sure you also push these changes out to any other branches that exist in
  the repo on GitHub via `Rebase` onto each branch. In this way, changes are
  always ready to be propagated to any/all other machines.
