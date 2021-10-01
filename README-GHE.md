# README-GHE

Use these instructions if you want the primary repos to be on an GitHub
Enterprise server with syncing to the GitHub instance.

# Setup from Scratch

Use these instructions when moving to a new GHE instance, i.e.; a new job.

## Create the GHE repos [![verified][]](#)

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

## Grab the GH repos [![verified][]](#)

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

## Push to GHE [![verified][]](#)

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

## Grab the GHE repos [![verified][]](#)

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

## Set up the branches [![verified][]](#)

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

## Set up dotfiles [![verified][]](#)

This step stores any existing existing dotfiles and links to new ones in the
repo.

```
$ cd $HOME/personal/dotfiles
$ . ./dotfilesbootstrap
$ cd ..
$ bin/makesymlinks -i dotfiles
```

## Test [![verified][]](#)

Before ending the existing terminal session, start up another one and make sure
that all the dotfile links are in place and everything works.

## Cleaning up [![verified][]](#)

You no longer need the GH clones:

```
for i in 'git_template' 'personal'; do
    cd /SomeTmpDir
    rm -rf $i
done
```

# Keeping the GHE and GH Repos in Sync [![inprogress][]](#)

We are going to avoid the use of the GitHub and GitHub Enterprise GUIs, as they
create superfluous merge commits. You can create pull requests if you wish,
just to see the diffs, and approve them for the audit trail, but never merge
them via the GUI.

We also assume that you are working on your live machine branch, so commits and
pushes happen on the repo in that directory.  You'll need another clone
of the repo to do all the merging work without disturbing the live repo.

## Setting up the non-live repo [![verified][]](#)

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

* Create tracking branches:

```
git branch --track gh-machine-branch gh/machine-branch
git branch --track gh-main gh/main
git branch -vv

  machine-branch     22423b6 [origin/machine-branch] Wrong remote ref
  gh-machine-branch  22423b6 [gh/machine-branch] Wrong remote ref
  gh-main         22423b6 [gh/main] Wrong remote ref
* main            22423b6 [origin/main] Wrong remote ref

```

## Sending GHE branch changes to GHE main and GitHub [![verified][]](#)

### Save branch changes

* After changes are committed, push commits to GitHub Enterprise from the live repo:

```
git push
```

* At this point, you can create a PR on GHE to review the diffs and even
  approve it for record keeping purposes, but **do not** use any of the methods
  on the GHE GUI to combine the code and close the PR; using the code combining
  methods below will automatically close the PR.

### Set up for the sync

Move to the non-live GHE repo to sync things up. From there, perform the following steps:

### Sync GHE main from the branch

In this instance, the source where the latest commits are is the `machine-branch`
branch and the target where you want those commits to be copied is the `main` branch:

```
source=machine-branch
target=main
```

What follows are the manual instructions. The script

```
bin/maint/git-sync-local $source $target
```

will perform them for you. The script should only be run in this non-live repo
and should not appear on `$PATH`.

* Refresh the repo:

```
git fetch --all --prune --tags

# You should see the changed branch fetched, something like:
# From ghe:gheusername/personal
   7e1e86f..c79a4b5  machine-branch      -> origin/machine-branch
```

* Refresh the source branch:

```
git switch ${source}
git pull
```

* Copy the new commits from the source branch onto the target branch and send
  them up to GHE:

```
git switch ${target}
git pull
git merge --ff-only ${source}
git push
```

### Sync GH machine-branch and GH main

In this instance, the source where the latest commits are is the `machine-branch`
branch and the targets where you want those commits to be copied are the
`machine-branch` and `main` on GitHub branch:

```
source=machine-branch
targets=(gh-machine-branch gh-main)
```

We also assume that the refreshes from the prior step are still in effect.

What follows are the manual instructions. The script

```
bin/maint/git-sync-ghe-gh "$source" "${targets[@]}"

```

will perform them for you. The script should only be run in this non-live repo
and should not appear on `$PATH`.

* Copy the new commits from the source branch onto each target:

```
for target in "${targets[@]}"; do
    git switch ${target}
    git pull
    git merge --ff-only ${source}
    git push gh HEAD:${target##gh-}
done
```

## Retrieving GitHub changes [![unverified][]](#)

We are assuming that all changes on GitHub are in the `gh-main` branch.

### Set up for the sync

Move to the non-live GHE repo to sync things up. From there, perform the following steps:

### Sync GHE machine-branch and GHE main

In this instance, the source where the latest commits are is the `gh-main`
branch and the targets where you want those commits to be copied are the
`machine-branch` and `main` GitHub Enterprise branches:

```
source=gh-main
targets=(machine-branch main)

```

These are the manual instructions. There is no script yet that will do this. Stay tuned.

* Refresh the repo:

```
git fetch --all --prune --tags

# You should see the changed branch fetched, something like:
# From ghe:ghusername/personal
   7e1e86f..c79a4b5  gh-main      -> ghe/main
```

* Refresh the source branch:

```
git switch ${source}
git pull
```

* Copy the new commits from the source branch onto each target:

```
for target in "${targets[@]}"; do
    git switch ${target}
    git pull
    git merge --ff-only ${source}
    git push gh HEAD:${target}
done
```

<!-- Links -->
[verified]: https://badges.dev.bloomberg.com/badge//Verified/green
[inprogress]: https://badges.dev.bloomberg.com/badge//Verification%20in%20progress/yellow
[unverified]: https://badges.dev.bloomberg.com/badge//unverified/red
