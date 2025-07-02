# README-direct

Use these instructions when you can set up the local code to directly talk to
GitHub.

# Setup

## ssh
Make a `${HOME}/.ssh` directory if it does not already exist. Set it `chmod 700`. Copy your `id_rsa` and `id_rsa.pub` files into the directory and set them `chmod 400`.

If you do not have ssh key file, see [Generating a new SSH key and adding it to the ssh-agent](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent)

## git
Execute the following to install the latest version of git:
```
sudo add-apt-repository ppa:git-core/ppa
sudo apt update
apt list --upgradable
sudo apt upgrade
```

## Local Software
We put stuff that we build in /opt/mop:
```
sudo mkdir -p /opt/mop/build
sudo chown -R ${USER} /opt
```

## Grab the repos

There are two - one for git templates and the personal repo with all the code.
We assume that you can reach the remote specified. Make sure you have your
'id_rsa' key and your ssh config set up to reach the server.

```
$ GH_REMOTE_REF=git@github.com:matthewpersico
$ cd $HOME
$ git clone ${GH_REMOTE_REF}/.git-template.git .git-template
$ vi ~/.gitconfig
    i[init]
    <TAB>templatedir = <EXPAND THE VALUE OF $HOME HERE>/.git-template
    :wq
$ git clone ${GH_REMOTE_REF}/personal.git personal
```

## Set up the branches

In each repo, you now have two choices:

### Make a machine-specific branch

For a new instance, If the hostname is unique, `branchname=$(hostname)` should
be sufficient. If not, try `branchname=$(hostname)-$(uname -s)`. When you have
a branch name, execute

```
for i in '.git-template' 'personal'; do
    cd ${HOME}/$i
    git checkout -b $branchname
    git push --set-upstream origin $branchname
done
```

### Use an existing branch name

If you are resetting an existing setup where the branch already exists:

```
for i in '.git-template' 'personal'; do
    cd ${HOME}/$i
    git checkout --track origin/EXISTING-BRANCH-NAME
done
```

Either way, we will refer to this branch as `machine-branch` later on.

## Set up dotfiles

This step stores existing dotfiles and links to new ones in the repo. The log file is so that you can have a record od what fails so that you can go back and correct it.

```
cd $HOME/personal/dotfiles
. ./dotfilesbootstrap
cd ..
bin/makesymlinks -i dotfiles 2>&1 | tee bin/makesymlinks.log
export REALGIT=$(which git)
bin/github.mopenv.init
git-kv --cat
```

## Test

Before ending the existing terminal session, start up a new login seesion and
make sure that all the dotfile links are in place and everything works. It
**must** be a login session to fully exercise the profiles. See also [Post
Setup](README.md#post_setup).

# Keeping things in sync

We are going to avoid the use of the GitHub GUI as it creates superfluous merge
commits. You can create pull requests if you wish, just to see the diffs, and
approve them for the audit trail, but never merge them via the GUI.

We also assume that you are working on your live machine branch, so commits and
pushes happen on the repo in that directory.  You'll need another clone
of the repo to do all the merging work without disturbing the live repo.

## Setting up the non-live repo

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
