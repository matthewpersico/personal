# WSL

* Install a distro.
* Install GWSL. If already installed and the distro is new, open GWSL up and make sure that GWSL Distro Tools > Display/Audio Auto-Exporting is set (check mark).
* Start up a session.
* Check GWSL integration:
```
echo $DISPLAY
```
* Open up sudo
```
sudo vi sudoers.$USER
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
* Alow emails to be sent out, esp. from cron
```
sudo apt install ssmtp
sudo vi /etc/ssmtp/ssmtpf.conf
<i>
root=matthew.persico@gmail.com
mailhub=smtp.gmail.com:465
hostname=<<hostname>>.localdomain
FromLineOverride=YES
AuthUser=matthew.persico@gmail.com
AuthPass=$(cat /mnt/c/Users/matth/Documents/ssh/Gmail*.txt)
UseTLS=YES
<esc:wq>
```
* Set up cron
```
sudo vi /etc/sudoers
<i>
%sudo ALL=NOPASSWD: /etc/init.d/cron start
<esc:wq>
crontab -e
<i>
MAILTO=matthew.persico@gmail.com
<esc:wq>
```
* Copy shortcuts in C:\Users\matth\Documents\WSL Stuff to shell:startup (Windows+r shell:startup). If they already exist, then reboot windows to restart them.
* Follow https://github.com/matthewpersico/personal/blob/main/README.md.

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
