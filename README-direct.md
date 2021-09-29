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
We are going to avoid the use of the GitHub GUI as it creates superfluous merge
commits. You can create pull requests if you wish, just to see the diffs, but
never approve them.

We also assume that you are working on your live machine branch, so commits and
pushes happen on that branch in the live directory.  You'll need another clone
of the repo to do all the work without disturbing the live repo.  The gist of
the actions is to be on the branch you want to update and then merge --ff-only the
branch with the changes onto the current branch.

## Sending branch changes to main
* After changes are committed, push commits to GitHub from the live repo:
```
git push
```
* Move to the non-livrepo to sync things up.
* Be on the `main` branch:
```
git switch main
```
* Refresh `main`:
```
git pull
```
* Refresh `mach-branch` (and any other references):
```
git fetch
```
* Copy the new commits from `mach-branch` onto `main`:
```
git merge --ff-only mach-branch
```
* Send 'em up to GitHub:
```
git push
```

## Getting main changes to a branch
* Move to the non-live repo to sync things up.
* Be on the `mach-branch` branch:
```
git switch mach-branch
```
* Refresh `mach-branch`:
```
git pull
```
* Refresh `main` (and any other references):
```
git fetch
```
* Copy the new commits from `main` onto `mach-branch`:
```
git merge --ff-only main
```
* Send 'em up to GitHub:
```
git push
```
