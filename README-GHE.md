# README-GHE
Use these instructions if you want the primary repos to be on an GitHub
Enterprise server with syncing to the GitHub instance.

# Setup

## Create the GHE repos
For each repo (`personal` and `git_template`), create a new, empty repo on
GitHub Enterprise.

When you do, you should be taken to a page that gives instructions on how to
continue using the repo. Note in particlar the commands for `...or push an
existing repository from the command line`. Make sure to copy the remote ref
for each repo; they will look something like:

```
git remote add origin git@the-ghe-server:your-GHE-name/personal.git
git push -u origin master
```

`git@the-ghe-server:your-GHE-name` is the `GHE_REMOTE_REF`.

## Grab the GH repos
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

## Push to GHE
Now, we push these repos onto GHE. This makes the GHE repo effectively a fork
of the GH repo.

```
for i in 'git_template' 'personal'; do
    cd /SomeTmpDir/$i
    git remote add ghe ${GHE_REMOTE_REF}/$i.git
    git push --set-upstream ghe main
done
```

## Grab the GHE repos
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

## Cleaning up
You no longer need the GH clones:
```
for i in 'git_template' 'personal'; do
    cd /SomeTmpDir
    rm -rf $i
done
```

# Keeping the GHE and GH Repos in Sync

## GHE -> GH

### GHE
GitHub Enterprise should be consistent before you attempt to sync with GitHub.

* Create a pull request on GitHub Enterprise from `mach-branch` into `main`.
  Resolve the PR via a `Rebase`; you can do with the GUI. Do not do a `Squash
  and merge` or a `Merge` into `main` via the GUI. Those actions will create
  cluttering Merge commit entries.
* Make sure you also push these changes out to any other branches that exist in
  the repo on GitHub Enterprise via `Rebase` onto each branch. In this way,
  changes are always ready to be propagated to any/all other machines.

### GH
* Push your changes up to GitHub:
```
git push gh mach-branch
```
* Create a pull request on GitHub from `mach-branch` into `main`. Resolve the
  PR via a `Rebase`; you can do this with the GUI. Do not do a `Squash and
  merge` or a `Merge` into `main` via the GUI. Those actions will create
  cluttering Merge commit entries.
* Make sure you also push these changes out to any other branches that exist in
  the repo on GitHub via `Rebase` onto each branch. In this way, changes are
  always ready to be propagated to any/all other machines.

And that's it. The commit histories of of `GHE/main`, `GHE/mach-branch`,
`GH/main`, and `GH/mach-branch` should all look the same.

## GH -> GHE
GitHub should be consistent before you attempt to sync with GitHub Enterprise.

### GH
* Make sure that all pull requests on GitHub have been resolved into `main` via
  a `Rebase`; you can do with the GUI. Do not do a `Squash and merge` or a
  `Merge` into `main` via the GUI. Those actions will create cluttering Merge
  commit entries.
* Make sure you also push these changes out to any other branches that exist in
  the repo on GitHub via `Rebase` onto each branch. In this way, changes are
  always ready to be propagated to any/all other machines.

### GHE
* Pull your changes down from GitHub:
```
git pull github mach-branch
```
* On GitHub Enterprise, create a pull request from `mach-branch` into
  `main`. Resolve the PR via a `Rebase` in GitHub Enterprise; you can do with
  the GUI. Do not do a `Squash and merge` or a `Merge` into `main` via the
  GUI. Those actions will create cluttering Merge commit entries.
* Make sure you also push these changes out to any other branches that exist in
  the repo on GitHub via `Rebase` onto each branch. In this way, changes are
  always ready to be propagated to any/all other machines.

And that's it. The commit histories of of `GHE/main`, `GHE/mach-branch`,
`GH/main`, and `GH/mach-branch` should all look the same.
