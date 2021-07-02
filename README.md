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

## Syncing between GHE and GH
It takes a bit of coordination to sync between GHE and GH. Here's how:

### Setup
* Clone repo from GHE.
* Add GH remote.
```
$ git remote add gh https://github.com/matthewpersico/personal
```
* Create a worktree.
```
$ git wt create --remote gh syncbbg
```
* Check remotes.
```
$ git remote -v
gh      https://github.com/matthewpersico/personal (fetch)
gh      https://github.com/matthewpersico/personal (push)
origin  bbgithub:mpersico5/personal (fetch)
origin  bbgithub:mpersico5/personal (push)
```

### Syncing to GHE -> GH
* Sync branch/worktree with GHE default branch.
```
git fetch origin
git merge remotes/origin/main
```
* Push to GH.
```
git push gh (--pr?)
```
* Create a PR on GH and merge it to default branch.
* Sync branch/worktree with GH default branch.
```
git fetch gh
git merge remotes/gh/master
```
* Push to GH.
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
