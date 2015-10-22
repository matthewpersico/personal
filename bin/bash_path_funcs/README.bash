
Path Manipulation Functions
---------------------------

This directory contains a set of functions for manipulating path variables,
such as PATH, MANPATH, LD_LIBRARY_PATH and so on.

How to set up your environment to access the functions
------------------------------------------------------

To run the path manipulation functions, you need to tell bash where to
find them. To do this, place the following lines in one of your bash
start-up scripts ($HOME/.bash_profile, for example):

source $HOME/bash_path_funcs/colon2line
source $HOME/bash_path_funcs/space2line
source $HOME/bash_path_funcs/Usage
source $HOME/bash_path_funcs/options
source $HOME/bash_path_funcs/makepath
source $HOME/bash_path_funcs/addpath
source $HOME/bash_path_funcs/delpath
source $HOME/bash_path_funcs/listpath
source $HOME/bash_path_funcs/uniqpath
source $HOME/bash_path_funcs/edpath
source $HOME/bash_path_funcs/realpath_filter

This assumes, of course, that you installed the files in $HOME/bash_path_funcs.
Modify the lines above appropriately if you installed them somewhere else.

Description of the functions
----------------------------

All the functions described below take the following common options.

-h                 : gives brief usage information
-p <path variable> : indicates which path variable to operate on.

By default, all functions operate upon PATH if the -p option is not supplied.

addpath
-------

Usage: addpath [-h] [-f|-b] [-p <pathvar>] <dirname>

    Idempotently adds <dirname> to <pathvar> (default: PATH)
    -f adds <dirname> to front of <pathvar> (default: PATH)
    -b adds <dirname> to back of <pathvar> (default: PATH)

This performs an idempotent addition of a path element to a path variable.
For example:

$ addpath /abc

adds /abc to the end of $PATH. Running this command again has no affect, as
/abc is already present in $PATH. That's what the "idempotent addition" means.

If you want to add to MANPATH instead, use the -p option, like so:

$ addpath -p MANPATH /abc

Note that you *don't* type "-p $MANPATH" in the last example, otherwise
the shell will expand MANPATH before addpath gets to see it. You can use
-f to add the path element to the front of the path variable, and -b to add
it to the back. (The default is -b, in fact, so it's not really needed).

delpath
-------

Usage: delpath [-e] [-n] [-p <pathvar>] <dirspec>

    deletes <dirname> from <pathvar> (default: PATH)
    -e: <dirname> is interpreted as an egrep regexp
    -n: delete non-existent path elements from <pathvar>

This deletes path elements from a path variable. For example:

$ delpath /abc

deletes the directory called /abc from $PATH, if it's present.

$ delpath -e "/opt.*/bin"

deletes deletes all directories matching the regular expression /opt.*/bin
from $PATH. (This would remove all bin directories under /opt from $PATH).

$ delpath -n

deletes all non-existent directories from $PATH. You can operate on other
path variables using the -p option.

edpath
------

Usage: edpath [-p <pathvar>]

    uses $EDITOR (default: vi) to edit <pathvar>
    -p: edit <pathvar> (default: PATH)

This allows you to fire up an editor (by default vi, if $EDITOR is not
set) and edit the contents of a path variable in any arbitrary way you wish.
The elements of the path appear on separate lines in the editor. You can,
for example, change the order of lines in the file, to modify the order in
which executables are found on your search path.

listpath
--------

Usage: listpath [-p <pathvar>]

    list elements of <pathvar> on separate lines
    -p: list <pathvar> (default PATH)

This writes the elements of the specified path variable to standard output
on separate lines. For example:

$ listpath
/opt/kde/bin
/usr/local/bin
/bin
/usr/bin
/usr/X11R6/bin
.
/usr/sbin
/usr/bin/X11
/ora01/app/oracle/product/7.3.2/bin

This makes it easier to read. You can also pipe the output of listpath into
grep, say:

$ listpath | grep "/bin$"
/opt/kde/bin
/usr/local/bin
/bin
/usr/bin
/usr/X11R6/bin
/home/stephen/bin
/ora01/app/oracle/product/7.3.2/bin

to see which bin directories are on your path.

uniqpath
--------

Usage: uniqpath [-p <pathvar>]

    Remove duplicate elements of <pathvar>
    -p: operate on <pathvar> (default: PATH)

This removes duplicated elements from a path variable. If you find that
multiple copies of a directory have been added to $PATH by /etc/PATH, for
example, you can clean it up by running:

$ uniqpath

at the top of $HOME/.profile, for example. (You could also do a "delpath -n"
for good measure, to get rid of non-existent directories that /etc/PATH
has added).

options
-------

This is a wrapper function around getopts. It is used in all of the
path manipulation functions described above. Take a look at the description
in the options file itself if you want to know how to use it, and look at
the code of the path functions for further examples of use.

Other functions
---------------

There are other functions listed below which are used internally in the
path variable functions.

Manifest
--------

The following files should be in the ksh_path_funcs directory.

README.bash
Usage
addpath
colon2line
delpath
edpath
listpath
makepath
options
realpath_filter
space2line
uniqpath

Contact Details
---------------

These utilities were written by Stephen Collyer (scollyer@netspinner.co.uk)
of Netspinner Limited, United Kingdom.

Warranty
--------

There is no warranty, or expressed or implied fitness for any particular
purpose, associated with the utilities described above.

Public Domain
-------------

The code for all the utilities described above is hereby placed in the
public domain. No license is required for usage or modification.

Please feel free to use of any of the code in any legal way that benefits you.

