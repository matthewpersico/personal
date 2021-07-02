# README
All my UNIX goodies including dotfiles so I can put them on any machine.

## Grab the repos
There are two - one for git templates and the personal repo with all the code.
We assume that you can reach the remote specified. Make sure you have your 'id_rsa' key and your ssh config set up to reach the server.

```
$ REMOTE=github:matthewpersico # or change as needed
$ cd $HOME
$ git clone ${REMOTE}/git_template .git_template
$ vi ~/.gitconfig
    i[init]
    <TAB>templatedir = <EXPAND THE VALUE OF $HOME HERE>/.git_template
    :wq
$ git clone ${REMOTE}/personal
$ cd personal
```

## Set up the branch
You now have two choices:
### Make a machine-specific branch
If the hostname is unique, `branchname=$(hostname)` should be sufficient. If not, try `branchname=$(hostname)-$(uname -s)`. When you have a branch name, execute
```
  $ git checkout -b $branchname
  $ git push --set-upstream origin $branchname
```
### Use an existing branch name
```
  $ git checkout --track origin/EXISTING-BRANCH-NAME
```

## Set up dotfiles
This step stores existing dotfiles and links to new ones in the repo.
```
$ cd dotfiles
$ . ./dotfilesbootstrap
$ cd ..
$ bin/makesymlinks -i dotfiles
```

## Test
Before ending the existing terminal session, start up another one and make sure that all the dotfile links are in place and everything works.

## Syncing from GHE to GH
It takes a bit of coordination to sync from GHE to GH. Here's how:

### Setup
* clone repo from GHE
* add GH remote:
```
git remote add gh https://github.com/matthewpersico/personal
```
* create a worktree
```
git wt create --remote gh syncbbg
```

### Syncing to GHE -> GH
* Sync branch/worktree with GHE default branch
```
git repo sync
```
* Push to GH
```
git push gh (--pr?)
```

### UNTESTED Syncing to GH -> GHE
* Sync branch/worktree with GH default branch
```
git-sync-with-remote --remote gh --branch main
```
* Push to GHE
```
git push --pr
```
