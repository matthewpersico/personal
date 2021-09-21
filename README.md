# README
All my UNIX goodies including dotfiles so I can put them on any machine.

## Grab the repos
There are two - one for git templates and the personal repo with all the code.
We assume that you can reach the remote specified. Make sure you have your
'id_rsa' key and your ssh config set up to reach the server.

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
If the hostname is unique, `branchname=$(hostname)` should be sufficient. If
not, try `branchname=$(hostname)-$(uname -s)`. When you have a branch name,
execute

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
Before ending the existing terminal session, start up another one and make sure
that all the dotfile links are in place and everything works.

## Syncing between GitHub Enterprise and public GitHub
When you are on your own machine, you can just use fork-clone workflow to keep
GitHub in sync across multiple machines.

However, trying to sync two instances of GitHub (usually a GitHub Enterprise at
work vs. public GitHub for personal stuff) is a bit different. The trick is to
get only the real updates from one to the other and not get hung up on all the
merge commit bookkeeping. To do that, we will need TWO separate worktrees and
branches, one in each repo. Each worktree/branch will sync in only one
direction, pulling in updates from the other repo. Any attempt to make one
worktree/branch sync in both directions will end up polluting one of the repos
with the bookeeping merge commit entries of the other.

## Sync from bbgithub (GHE) to GitHub (GH)

### Setup

* Clone the GitHub repo.

```
$ github-clone matthewpersico/personal
```

* Make a worktree `from-bbg`. The worktree is also on the branch `from-bbg`.

```
$ git worktree create from-bbg
```

* Add `bbgh` as a remote to access GitHub Enterprise.

```
$ git remote add bbgh bbgithub:mpersico5/personal
$ git remote -v
bbgh    bbgihhub:mpersico5/personal (fetch)
bbgh    bbgihhub:mpersico5/personal (push)
origin  https://github.com/matthewpersico/personal (fetch)
origin  https://github.com/matthewpersico/personal (push)
```

That ends the setup.

### Sync
In this situation, there are commits in GHE (bbgithub) that are not on GH
(github.com) and the local disk copy of `from-bbg` is up to date with respect
to its origin, github.com.

* Get the new commits from BBGitHub.

```
$ git fetch bbgh
```

* Merge them in.

```
$ git merge bbgh/main
```

* Send them up to GitHub.

```
$ git push
```

* Create a PR on GitHub from-bbg => main. Use the Merge method to merge it.

* Update the local copy of the `from-bbg` branch.

```
$ git repo sync
```

## Pull from GitHub (GH) to bbgithub (GHE)

### Setup
* Clone the GitHub Enterprise repo.

```
$ bbgithub-clone mpersico5/personal
```

* Make a worktree `from-gh`. The worktree is also on the branch `from-gh`.

```
$ git worktree create from-gh
```

* Add `gh` as a remote to GitHub.

```
$ git remote add gh https://github.com/matthewpersico/personal
$ git remote -v
gh      https://github.com/matthewpersico/personal (fetch)
gh      https://github.com/matthewpersico/personal (push)
origin  bbgithub:mpersico5/personal (fetch)
origin  bbgithub:mpersico5/personal (push)
```

That ends the setup.

### Sync
In this situation, there are commits in GH (github.com) that are not on GitHub
Enterprise (bbgithub) and the local disk copy of `from-gh` is up to date with
respect to its origin, bbgithub.

* Get the new commits from GitHub.

```
$ git fetch gh
```

* Merge them in.

```
$ git merge gh/main
```

* Send them up to BBGitHub.

```
$ git push
```

* Create a PR on BBGitHub from-gh => main. Use the Merge method to merge it.

* Pull main down from BBGitHub to some other directory. Get rid of the Merge
  commit entry with

```
git reset --hard commit-before-HEAD
```

where `commit-before-head` is the SHA of the last real commit in the merge. Do
not blindly use `HEAD~1`; it does not seem to be consistent.

* Push main up to BBGitHub, --force because you are pushing a branch missing a
  commit.

```
git push --force
```

* Update the local copy of the `from-gh` branch.

```
$ git repo sync
```
