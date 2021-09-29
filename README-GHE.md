# README-GHE
Use these instructions if you want the primary repos to be on an GitHub
Enterprise server with syncing to the GitHub instance.

# Setup

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
$ git clone ${GH_REMOTE_REF}/git_template
$ vi ~/.gitconfig
    i[init]
    <TAB>templatedir = /SomeTmpDir/git_template
    :wq
$ git clone ${GH_REMOTE_REF}/personal
```

## Push to GHE [![verified][]](#)
Now, we push these repos onto GHE. This makes the GHE repo effectively a fork
of the GH repo.

```
for i in 'git_template' 'personal'; do
    cd /SomeTmpDir/$i
    git remote add ghe ${GHE_REMOTE_REF}/$i.git
    git push --set-upstream ghe main
done
```

## Grab the GHE repos [![verified][]](#)
Now we will grab the GitHub Enterprise repos and put them in the home
directory to use. We will also establish a remote back to their GitHub repos.

```
$ cd ${HOME}

$ git clone ${GHE_REMOTE_REF}/git_template .git_template
$ cd ${HOME}/.git_template
$ git remote add github github:matthewpersico/git_template
$ cd ${HOME}
$ vi ~/.gitconfig
    i[init]
    <TAB>templatedir = ${HOME}/.git_template
    :wq

$ git clone ${GHE_REMOTE_REF}/personal
$ cd ${HOME}/personal
$ git remote add github github:matthewpersico/personal
```

## Set up the branches [![verified][]](#)
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
    git push --set-upstream github $branchname
done
```

### Use an existing branch name
If you are resetting an existing setup where the branch already exists:
```
for i in '.git_template' 'personal'; do
    cd ${HOME}/$i
    git checkout --track origin/EXISTING-BRANCH-NAME
    git push --set-upstream github EXISTING-BRANCH-NAME
done
```

Either way, we will refer to this branch as `mach-branch` later on.

## Set up dotfiles [![verified][]](#)
This step stores existing dotfiles and links to new ones in the repo.

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
We are going to avoid the use of the GitHub GUI as it creates superfluous merge
commits. You can create pull requests if you wish, just to see the diffs, but
never approve them.

We also assume that you are working on your live machine branch, so commits and
pushes happen on that branch in the live directory.  You'll need another clone
of the repo to do all the work without disturbing the live repo.  The gist of
the actions is to be on the branch you want to update and then merge --ff-only the
branch with the changes onto the current branch.

## Setting up the non-live repo [![verified][]](#)

* Clone the GHE repo to a non-temp location.
* Create a remote to the GitHub repo:
```
git remote add gh github:matthewpersico/personal
git fetch gh
```
* Create tracking branches:
```
git branch --track gh-mach-branch gh/mach-branch
git branch --track gh-main gh/main
git branch -vv

  mach-branch     22423b6 [origin/mach-branch] Wrong remote ref
  gh-mach-branch  22423b6 [gh/mach-branch] Wrong remote ref
  gh-main         22423b6 [gh/main] Wrong remote ref
* main            22423b6 [origin/main] Wrong remote ref
```
## Sending GHE branch changes to GHE main and GitHub [![verified][]](#)

### Save branch changes
* After changes are committed, push commits to GitHub Enterprise from the live repo:
```
git push
```

### Set up for the sync
Move to the non-live GHE repo to sync things up. From there, perform the following steps:

### Sync GHE main
These are the manual instructions. The script `bin/maint/git-sync-local` will
perform them for you. The script should only be run in this non-live repo and
should not appear on `$PATH`.

* Refresh the repo:
```
git fetch --all --prune --tags

# You should see the changed branch fetched, something like:
# From ghe:gheusername/personal
   7e1e86f..c79a4b5  mach-branch      -> origin/mach-branch
```

* Set the `mach-branch` branch:
```
mb='mach-branch'
```
* Refresh the `mach-branch` branch:
```
git switch ${mb}
git pull
```
* Copy the new commits from `mach-branch` onto `main`:
```
git switch main
git pull
git merge --ff-only ${mb}
```
* Send 'em up to GHE:
```
git push
```

### Sync GH mach-branch and GH main
These are the manual instructions. The script `bin/maint/git-sync-ghe-gh` will
perform them for you. The script should only be run in this non-live repo and
should not appear on `$PATH`.

* Copy the new commits from `mach-branch` onto `gh-mach-branch`:
```
git switch gh-${mb}
git pull
git merge --ff-only ${mb}
```
* Send 'em up to GHE:
```
git push gh HEAD:${mb}
```
* Copy the new commits from `mach-branch` onto `gh-main`:
```
git switch gh-main
git pull
git merge --ff-only ${mb}
```
* Send 'em up to GHE:
```
git push gh HEAD:main
```

## Retrieving GitHub changes [![unverified][]](#)
We are assuming that all changes on GitHub have been distributed from `main` to
all the `mach-branch` branches. We will use the `gh-mach-branch` to update
GHE's `mach-branch` and `main`.

* Move to the non-live GHE repo to sync things up.
* Refresh the repo:
```
git fetch --all --prune --tags
# You should see the changed branch fetched, something like:
# From gh:matthewpersico/personal
   7e1e86f..c79a4b5  mach-branch      -> gh/mach-branch
```
* Set the `mach-branch` branch:
```
mb='mach-branch'
```
* Refresh the `gh-mach-branch` branch:
```
git switch gh-${mb}
git pull
```
* Copy the new commits from `gh-mach-branch` onto `gmach-branch`:
```
git switch ${mb}
git pull
git merge --ff-only gh-${mb}
```
* Send 'em up to GHE:
```
git push
```
* Copy the new commits from `gh-mach-branch` onto `main`:
```
git switch main
git pull
git merge --ff-only gh-${mb}
```
* Send 'em up to GHE:
```
git push
```
<!-- Links -->
[verified]: https://badges.dev.bloomberg.com/badge//Verified/green
[inprogress]: https://badges.dev.bloomberg.com/badge//Verification%20in%20progress/yellow
[unverified]: https://badges.dev.bloomberg.com/badge//unverified/red
