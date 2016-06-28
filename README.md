# personal
All my UNIX goodies including dotfiles so I can put them on any machine.

Feel free to peruse. I keep all my personal goodies in ~/personal; that's where
bin, lib, et. al. live. Also under there is dotfiles, which is the source for
all my dot files and the location for the scripts I use to dotfiles and their
links in sync.

Right now, I use a chef recipe to spin up a VM. Initially, Once up, I logged
in, git clone'ed this repo, ran dotfiles/makesymlinks and then, with luck, I
would have an environment that I can use. Recently, however, I moved my home
dir to remote mounted storage which survives VM rebuilds. But git clone and
dotfiles/makesymlinks should still work.


My .emacs.d directory is not included in this setup at this time. It is
actually a clone of https://github.com/philippe-grenet/exordium.git, so I have
some work to do in order to put a fork up on bbgithub and keep it all in
sync. Look for mpersico5/.emacs Real Soon Now.

****WARNING**** As always, a Work In Progress. I do try to eat lots of dogfood
    before I push but I don't have unit tests. Caveat Programmer.
