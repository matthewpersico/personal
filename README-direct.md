# README-direct

Use these instructions when you can set up the local code to directly talk to
GitHub.

# Setup

## ssh
Make a `${HOME}/.ssh` directory if it does not already exist. Set it `chmod 700`. Copy your `id_rsa` and `id_rsa.pub` files into the directory and set them `chmod 400`.

If you do not have ssh key file, see [Generating a new SSH key and adding it to the ssh-agent](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent)

## git

Execute the following to install the latest version of git.
```
sudo -i
```
```
add-apt-repository ppa:git-core/ppa
apt update
apt list --upgradable
apt upgrade
exit #sudo
```

## Local Software

We put stuff that we build in /opt/mop.
```
sudo mkdir -p /opt/mop/build
sudo chown -R ${USER} /opt/mop
```

## Grab the repos

There are two - one for git templates and the personal repo with all the code.
We assume that you can reach the remote specified. Make sure you have your
'id_rsa' key and your ssh config set up to reach the server.

```
cd $HOME
pwd
GH_REMOTE_REF=git@github.com:matthewpersico
git clone ${GH_REMOTE_REF}/.git-template.git .git-template
```
```
vi ~/.gitconfig
    i[init]
    <TAB>templatedir = <EXPAND THE VALUE OF $HOME HERE>/.git-template
    :wq
```
```
git clone ${GH_REMOTE_REF}/personal.git personal
```

## Set up the branches

In each repo, you now have two choices:

### Make a machine-specific branch

For a new instance, if the hostname is unique, `machine_branch=$(hostname)` should
be sufficient. If not, try `machine_branch=$(hostname)-$(uname -s)`. When you have
`$machine_branch` set, execute

```
for i in '.git-template' 'personal'; do
    cd ${HOME}/$i
    pwd
    git checkout -b $machine_branch
    git push --set-upstream origin $machine_branch
done
```

### Use an existing branch name

If you are resetting an existing setup where the branch already exists:

```
for i in '.git-template' 'personal'; do
    cd ${HOME}/$i
    pwd
    git checkout --track origin/$machine_branch
done
```

## Set up dotfiles

This step stores existing dotfiles and links to new ones in the repo. The log
file is created in order that you can have a record of what fails so you can go
back and correct it.

```
cd $HOME/personal/dotfiles
pwd
. ./dotfilesbootstrap
cd ..
pwd
bin/makesymlinks -i dotfiles 2>&1 | tee bin/makesymlinks.log
export REALGIT=$(which git)
bin/github.mopenv.init
git-kv --cat
```
## X11

Use the computer's package manager and install whatever package you need
to be able to run 'xterm'. If you do not, then you may have a problem such
that trying to login directly to a machine using a graphical interface will
try and run with /bin/sh. Your .bash_profile will not be sourced. By
installing xterm with the package manager, the xterminit setup will be run
at the proper time, all shells should be login shells and everything "Just Works".
Or, at least that's what happened when I was adapting this repo to a Raspian
setup in Feb 2026. Nothing worked until I installed 'xterm'.

## Test

Before ending the existing terminal session, start up a new login seesion and
make sure that all the dotfile links are in place and everything works. It
**must** be a login session to fully exercise the profiles. See also [Post
Setup](README.md#post_setup).

# Keeping things in sync

We are going to avoid the use of the GitHub GUI as it creates superfluous merge
commits. You can create pull requests if you wish, just to see the diffs, and
approve them for the audit trail, but never merge them via the GUI.

We also assume that you are working on your live `$machine branch`, so commits
and pushes happen on the repo in that directory.  You'll need another clone of
the repo to do all the merging work without disturbing the live repo.

> Note: Although we are demonstrating sync'ing the `personal` repo here,
> nothing would keep you from sync'ing any other repo. The most common other
> one to sync is the `emacs.taps` repo.

## Setting up the non-live repo

* Clone the GH repo

```
github-clone matthewpersico/personal
```

* Setup `$machine_branch`

Execute `git branch --list --all`. Ignoring the `remotes/origin/HEAD` branch,
for each `remotes/origin/FOO` branch that does not have a corresponding local
`FOO` branch, execute `git checkout --track origin/FOO`. Any time you add a new
source branch to the github repo, come back to the non-live repo and run
`git checkout --track origin/newBranchName` so that future syncs take the
new remote branch into account. You will have to do this on every machine
from which you sync the `personal` repo.

## Sending branch changes to all other branches

### Save branch changes

* After changes are committed, push commits to GitHub from the live repo:

```
git push
```

* At this point, you can create a PR on GH to review the diffs and even approve
  it for record keeping purposes, but **do not** use any of the methods on the
  GH GUI to combine the code and close the PR; using the code combining methods
  below will automatically close the PR.

### Sync

* Move to the non-live repo
* Execute

```
git branch --sync <source-branch>
```

The command will refresh local and remote branches and then propagate the
changes on the specified branch to all the others. If you do not specify
a branch, then all the refreshed branches will be checked for their latest
commit time. The one with the latest change will be offered up for confirmation
to have its changes merged into all the others.

In an ideal situation, all but one of the branches should be on the same commit.
That differing commit should be latest one and it will be chosed for propigation.
If some branches are on the latest commit and all the others are on the same earlier
commit, then that's ok. Just propagate the lastest commit from one source and it
will get to just the branches with the earlier commit.

The worst situation is that there are three or more distinct commits in the list.
In this case, you will need to examine all the commits and manually what order int
which to do the merges across branches in order to not lose any commits or create
conflicts. In order NOT to get into this situation, try to do all development
on one machine and propigate out. Make sure you sync frequently. Check before you
start making changes and do a commit and sync on other machines before you develop
on the current machine.

## Getting main changes to all other branches

There is nothing special about propagating changes on `main` back out to the
machine branches; all you are doing is swapping the source and the target.

```
git branch --sync main
```
