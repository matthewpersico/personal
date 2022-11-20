# WSL

* Install a distro.
* Start up a session.
* Pin the icon to the taskbar.
* Check WSLg integration:
```
$ echo $DISPLAY
:0
$ ls -la /tmp/.X11-unix
total 4
drwxrwxrwx 2 root    root      60 Oct  8 17:15 .
drwxrwxrwt 3 root    root    4096 Oct  8 17:15 ..
srwxrwxrwx 1 matthew matthew    0 Oct  8 17:15 X0
```
If the two numbers match, you're good. If not, change the `DISPLAY` variable to match.
* Open up sudo
```
sudo vi sudoers.$USER
<:syntax off>
<i>
<$USER> ALL=(ALL) NOPASSWD:ALL
<esc:wq>
```
```
sudo chown root:root sudoers.$USER
sudo chmod 664 sudoers.$USER
sudo mv sudoers.$USER /etc/sudoers.d/$USER
```
* Add git and emacs dpkg repos
```
sudo apt-add-repository ppa:git-core/ppa
sudo add-apt-repository ppa:kelleyk/emacs
```
* Update the system
```
sudo apt update
sudo apt upgrade
```
* Add X support
```
sudo apt install x11-apps -y
xterm & # to test
```
* Allow emails to be sent out, esp. from cron. Reference: https://www.nixtutor.com/linux/send-mail-with-gmail-and-ssmtp/
```
sudo apt install ssmtp

sudo vi /etc/ssmtp/ssmtp.conf
<:syntax off>
<i>
root=matthew.persico@gmail.com
mailhub=smtp.gmail.com:587
hosdtname=MONOLITH
FromLineOverride=YES
AuthUser=matthew.persico@gmail.com
AuthPass=$(cat /mnt/c/Users/matth/Documents/ssh/Gmail*.txt)
UseSTARTTLS=YES
<esc:wq>

sudo vi /etc/ssmtp/revaliases
<:syntax off>
<i>
root:root@MONOLITH:smtp.gmail.com:587
matthew:matthew@MONOLITH:smtp.gmail.com:587
<esc:wq>

# Testing...
ssmtp matthew.persico@verizon.net <<EOD
Subject: This is a test
Line 1
Line 2
Line 3
EOD
```
**Note:** If you don't have smtp for some reason, try:
```
cat <<EOCRONCONF > /tmp/crond
# Settings for the CRON daemon.
# CRONDARGS= :  any extra command-line startup arguments for crond
CRONDARGS='-m /home/<USER>/personal/bin/local-mailme-cron'
EOCRONCONF

sudo mv /tmp/crond /etc/sysconfig/crond
sudo chmod 600 /etc/sysconfig/crond
sudo service crond status
sudo service crond restart
sudo service crond status
```

* Set up cron
```
sudo vi /etc/sudoers.d/cron
<:syntax off>
<i>
%sudo ALL=NOPASSWD: /etc/init.d/cron start
<esc:wq>
# Do the following for crontab -e and sudo crontab -e
<i>
MAILTO=matthew.persico@gmail.com
<esc:wq>
```
* Copy shortcuts in C:\Users\matth\Documents\WSL Stuff to shell:startup (Windows+r shell:startup). If they already exist, then reboot windows to restart them.
* Follow https://github.com/matthewpersico/personal/blob/main/README.md .

WIP:

* sudo apt install...
** yad
** git
** firefox
** x11-xserver-utils
** libx11-dev
** xterm
** x11-apps
** devscripts
** make
** gcc
** emacs27
** ispell
** shellcheck
** plenv (https://github.com/tokuhirom/plenv)
-** now check the perl stuff since we are not going to update system perl
-** cpanminus
-** perltidy
-** libterm-readline-gnu-perl
-** perl-doc
-** perl-tk
-** libdevel-ptkdb-perl
-** libfile-slurp-perl
-** libpath-tiny-perl
-** liblingua-en-inflect-perl
** Not sure about these
*** pango-querymodules
*** pango-querymodule
*** libpango-bin
*** libgdk-pixbuf-bin
*** python-markdown
*** markdown
* sudo cpanm
** Pod::PseudoPod
** App::pod2pdf
