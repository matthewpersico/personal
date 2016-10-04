# README #

### What is this repository for? ###

A set of shell scripts I use for convenience in various places.

### How do I get set up? ###

* cd ~
* git clone git@github.com:matthewpersico/personal.git personal
* cd personal/dotfiles
* ./dotfilesfuncs
* makesymlinks
* makepstree
* cd ..
* Make a machine-specific branch. If the hostname is unique, use that. If not,
try $(hostname)-$(uname -o). When you have a branch name, execute
  * git checkout -b branchname
  * git push --set-upstream origin branchname
