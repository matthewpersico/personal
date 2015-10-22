# personal
All my UNIX goodies including dotfiles so I can put them on any machine.

Feel free to peruse. I keep all my personal goodies in ~/personal; that's where bin, lib, et. al. live. Also under there is
dotfiles, which is the source for all my dot files and the location for the scripts I use to dotfiles and their links in sync.

Right now, I use a chef recipe to spin up a VM. Once up, I log in, git clone this repo, run dotfiles/makesymlinks and then, with
luck, I have an environment that I can use.

My .emacs.d directory is not included in this setup at this time. It is actually a clone of https://github.com/philippe-grenet/exordium.git,
so I have some work to do in order to put a fork up on bbgithub and keep it all in sync. Look for mpersico5/.emacs Real Soon Now.

****WARNING**** Work In Progress - none of this is tested yet. Caveat Programmer.
