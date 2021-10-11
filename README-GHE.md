# README-GHE

Use these instructions if you want the primary repos to be on an GitHub
Enterprise server with syncing to the GitHub instance.

# Setup from Scratch

Use these instructions when moving to a new GHE instance, i.e.; a new job.

## Create the GHE repos

For each repo (`personal` and `git_template`), create a new, empty repo on
GitHub Enterprise.

When you do, you should be taken to a page that gives instructions on how to
continue using the repo. Note in particular the commands for `...or push an
existing repository from the command line`; they will look something like:

```
git remote add origin git@the-ghe-server:your-GHE-name/personal.git
git push -u origin master
```

`git@the-ghe-server:your-GHE-name` is the `GHE_REMOTE_REF`. Note it for
subsequent steps.

## Grab the GH repos

We assume that you can reach the remote specified. Make sure you have your
'id_rsa' key and your ssh config set up to reach the server.

```
$ GH_REMOTE_REF=github:matthewpersico # or change as needed
$ cd /SomeTmpDir
$ git clone ${GH_REMOTE_REF}/.git-template
$ vi ~/.gitconfig
    i[init]
    <TAB>templatedir = /SomeTmpDir/.git-template
    :wq
$ git clone ${GH_REMOTE_REF}/personal
```

## Push to GHE

Now, we push these repos onto GHE. This makes the GHE repo effectively a fork
of the GH repo. Set `GHE_REMOTE_REF` as needed.

```
for i in 'git_template' 'personal'; do
    cd /SomeTmpDir/$i
    git remote add ghe ${GHE_REMOTE_REF}/$i.git
    git push --set-upstream ghe main
done
```

# Setting up a New Instance

Use these instructions when setting up a new home directory with new repos.

## Grab the GHE repos

We will clone the GitHub Enterprise repos and put them in the home directory to
use.

```
$ cd ${HOME}
$ git clone ${GHE_REMOTE_REF}/.git-template
$ vi ~/.gitconfig
    i[init]
    <TAB>templatedir = ${HOME}/.git-template
    :wq
$ git clone ${GHE_REMOTE_REF}/personal
```

## Set up the branches

In each repo, you now have two choices:

### Make a machine-specific branch

For a new instance, If the hostname is unique, `branchname=$(hostname)` should
be sufficient. If not, try `branchname=$(hostname)-$(uname -s)`. When you have
a branch name, execute

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

Either way, we will refer to this branch as `machine-branch` later on.

## Set up dotfiles

This step stores any existing existing dotfiles and links to new ones in the
repo.

```
$ cd $HOME/personal/dotfiles
$ . ./dotfilesbootstrap
$ cd ..
$ bin/makesymlinks -i dotfiles
```

## Test

Before ending the existing terminal session, start up another one and make sure
that all the dotfile links are in place and everything works.

## Cleaning up

You no longer need the GH clones:

```
for i in 'git_template' 'personal'; do
    cd /SomeTmpDir
    rm -rf $i
done
```

# Keeping the GHE and GH Repos in Sync

We are going to avoid the use of the GitHub and GitHub Enterprise GUIs, as they
create superfluous merge commits. You can create pull requests if you wish,
just to see the diffs, and approve them for the audit trail, but never merge
them via the GUI.

We also assume that you are working on your live machine branch, so commits and
pushes happen on the repo in that directory.  You'll need another clone
of the repo to do all the merging work without disturbing the live repo.

## Setting up the non-live repo

* Clone the GHE repo to a non-temp location.

* Setup `machine-branch`

```
git checkout --track origin/machine-branch
```

* Create a remote to the GitHub repo:

```
git remote add gh github:matthewpersico/personal
git fetch gh
```

* Create the tracking branch:

```
git branch --track gh-machine-branch gh/machine-branch
git branch -vv

  machine-branch     22423b6 [origin/machine-branch] Wrong remote ref
  gh-machine-branch  22423b6 [gh/machine-branch] Wrong remote ref
* main            22423b6 [origin/main] Wrong remote ref

```

## Sending GHE branch changes to GHE main and GitHub

### Save branch changes

* After changes are committed, push commits to GitHub Enterprise from the live repo:

```
git push
```

* At this point, you can create a PR on GHE to review the diffs and even
  approve it for record keeping purposes, but **do not** use any of the methods
  on the GHE GUI to combine the code and close the PR; using the code combining
  methods below will automatically close the PR.

### Sync

* Move to the non-live GHE repo to sync things up.
* Execute

```
ghe-to-gh machine-branch
```

The command will refresh local and remote branches and then propagate the
changes on the specified branch to all the others on "origin" and to the
gh-machine-branch branch on GitHub. It is up to you to then sync branches on
GitHub separately.

## Retrieving GitHub changes

We are assuming that all changes on GitHub are in the `gh-machine-branch` branch.

### Sync

* Move to the non-live GHE repo to sync things up.
* Execute

```
ghe-from-gh machine-branch
```

The command will refresh local and remote branches and then propagate the
changes on the 'gh-machine-branch' to 'machine-branch'. It is up to you to then
sync branches on GitHub Enterprise separately.
