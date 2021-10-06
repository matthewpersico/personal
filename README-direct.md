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

We are going to avoid the use of the GitHub GUI as it creates superfluous merge
commits. You can create pull requests if you wish, just to see the diffs, and
approve them for the audit trail, but never merge them via the GUI.

We also assume that you are working on your live machine branch, so commits and
pushes happen on the repo in that directory.  You'll need another clone
of the repo to do all the merging work without disturbing the live repo.

## Setting up the non-live repo [![verified][]](#)

* Clone the GH repo to a non-temp location.

* Setup `machine-branch`

```
git checkout --track origin/machine-branch
```

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

* Move to the non-live GHE repo to sync things up.
* Execute

```
git branch --sync machine-branch
```

The command will refresh local and remote branches and then propagate the
changes on the specified branch to all the others.

## Getting main changes to all other branches

There is nothing special about propagating changes on `main` back out to the
machine branches; all you are doing is swapping the source and the target.

### Sync

* Move to the non-live GHE repo to sync things up.
* Execute

```
git branch --sync main
```
