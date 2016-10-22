# README
All my UNIX goodies including dotfiles so I can put them on any machine.

* cd ~
* git clone <THIS REPO> personal
* cd personal/dotfiles
* ./dotfilesfuncs
* makesymlinks
* makepstree
* cd ..
* Make a machine-specific branch. If the hostname is unique, ```branchname=$(hostname)```. If not,
try ```branchname=$(hostname)-$(uname -o)```. When you have a branch name, execute
  * git checkout -b $branchname
  * git push --set-upstream origin $branchname
