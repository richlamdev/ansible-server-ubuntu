# Ansible Playbook for configuring Ubuntu Server (minimal)

## Introduction

This is a collection of roles and configuarions I use for Ubuntu Server
deployment.

This playbook was primarily created for deploying [Unbound DNS](https://www.nlnetlabs.nl/projects/unbound/about/) server with
[Unbound-adblock](https://geoghegan.ca/unbound-adblock.html).

Unbound-adblock is essentially a DNS filter that blocks ads and trackers,
similar to [pi-hole](https://pi-hole.net/).

This Playbook is designed and tested for Ubuntu Server 24.04.1 LTS.  This
playbook may not work on older versions of Ubuntu without modification.


## Requirements

1) Basic knowledge of Ansible

2) Ubuntu Server 24.04.1 (may work on other apt based distros with modification)

3) Software: ansible, git, openssh-server, vim-gtk3 (vim or vim-gtk3 is not
strictly required, but is required if the vim role is executed)

4) Ensure ansible community modules are installed. See below for instructions.


## Instructions

*This assumes a new/fresh installation and the execution of this playbook
is on the target machine (localhost).  Of course, this playbook can be executed
to a remote host, if needed.  This also assumes the user indicated
below by \<username\> belongs to the sudo group.  Additionally, this assumes
the user's primary group on the host and target machine(s) are the same.*

1. Install required software for this playbook.\
`sudo apt update && sudo apt install ansible git vim -y`
`ansible-galaxy collection install community.general`

2. Clone ansible-desktop-ubuntu repo.\
`git clone https://github.com/richlamdev/ansible-desktop-ubuntu.git`

3. Generate SSH key pair for localhost.\
`cd ansible-desktop-ubuntu/scripts`

The following script will generate a new SSH key pair for localhost and copy
the public key to ~/.ssh/authorized_keys.  This will allow authentication
via SSH key.\
`./gen_ssh_keys.sh`

Alternatively, if password authentication is preferred, install sshpass.\
`sudo apt install sshpass`

** *Limit use of sshpass for setup only, due to potential security issues. * **

Note: Be aware /role/base/tasks/ssh.yml will update the sshd_config indirectly
by the configuration file placed in /etc/ssh/sshd_config.d/, this will disable
SSH password authentication; consequently, making SSH key-based authentication
a hard requirement.

4. Amend inventory file if needed, default target is localhost.

5. Amend main.yml file for roles (software) desired.

* The majority of third party packages are separated into roles, this was
setup this way to allow convenient inclusion/exclusion of roles as needed by
commenting/uncommenting roles in main.yml at the root level of the repo.

6. To run the playbook use the following command:\
`ansible-playbook main.yml -bKu <username> --private-key ~/.ssh/<ssh-key>`
  * enter SUDO password. (assumes user is a member of the sudo user group)

To run the playbook using SSH password authentication, use the following
command:\
`ansible-playbook main.yml -bkKu <username>`
  * enter SSH password
  * enter SUDO password. (assumes user is a member of the sudo user group)

7. Where privilege escalation is not required, the packages or configuration is
installed on the target host(s) in the context of \<username\> indicated.


## Role Information

The majority of roles are self explantory in terms of what they install.

Additional information for the following roles:

* apt-sources-ubc
  * adds University of BC (UBC) as primary apt source
  * this is a personal preference for me
  * find your fastest/closest mirror [here](https://launchpad.net/ubuntu/+archivemirrors)

* auto-update
  * force dpkg to accept default settings during updates
  * add cron to run apt update and dist-upgrade daily
  * add cron to run snap update daily
  * technically there are built-in methods to run apt and snap update daily
    (unattended-upgrades), however, none of those methods seem to work.
    This primitive implementation achieves a similar effect.
  * This role is for any desktop/laptop that requires operating 24/7.
  * There is a basic script (check_reboot.sh) to check if a reboot is required,
    which is scheduled to run daily at 0400hrs.(checks for presence of
    /var/run/reboot-required)

* base
  * packages.yml - list of packages to install via apt
  * keychron.yml - enables keychron keyboard shortcuts
  * autostart.yml - enables autostart of applications
  * ssh.yml - configures ssh server and client.
                         disables password authentication

* disable-local-dns
  * disables local dns on the target host
    (again this is a personal preference, as my network DNS server handles
    DNS lookup and filtering)
  * this role is executed last, as a dns service restart is required; the
    restart will take too long and cause the following playbook role(s) to fail
    (a delay could be added, but that adds unnecessary execution time for the
    playbook)

* env
  * setups personal preferences for bash shell
  * fzf is required for [fzf.vim](https://github.com/junegunn/fzf.vim)
  * .bashrc -bash function `se` is for fast directory navigation at the CLI
    refer to [fzf explorer](https://thevaluable.dev/practical-guide-fzf-example/)
    (this is slightly different from the built in alt-c command provided with fzf)
  * refer to System Updates section for manual (script) updating of fzf

* ntp-via-dhcp
  * configures NTP to use DHCP to obtain NTP server IP address for each interface found
    * attempts to obtain all physical local ethernet and wireless interfaces
    * attempts to disregard any loopback interfaces and virtual interfaces
    * assumes that DHCP is sending NTP server IP address to the subnet the interface is assigned to
  * confirm NTP server with any of the following commands:
    * `timedatectl timesync-status`
    * `timedatectl show-timesync --all`
    * `journalctl -u systemd-timesyncd -n 20 | grep -A5 "Network Time Synchronization"`

* unbound
  * installs and configures unbound DNS server
  * enables DNSSEC
  * enables DNS-over-TLS via Quad9, CloudFlare, Mulvadd, Adguard DNS service
    providers; refer to /etc/unbound/unbound.conf.d/20-forward-zones.conf
  * add custom local dns records by editing\
    /etc/unbound/unbound.conf.d/10-local-dns.conf.example as needed;\
    the save the file without the .example extension when done
  * allows incoming TCP and UDP connections on port 53 via ufw

* unbound-adblock
  * all credit for this role goes to [Jordan Geoghegan](https://www.geoghegan.ca/about.html).  I did not write this,
    I only transferred the implementation from Bash to Ansible.
  * Refer to Unbound Adblock [webpage](https://www.geoghegan.ca/unbound-adblock.html)

* vim (this role is commented out by default)
  * installs customization only, does not install vim
    * compile and install vim with this [script](https://github.com/richlamdev/vim-compile)
    * Note: Vim >9.0 is required for codeium plugin below, at the time of the
    writing of this playbook, Vim 9.x was not available in the official Ubuntu
    repos

  * if codeium is not needed, disable codeium in the status line within .vimrc
    that is deployed with this role:
    * comment out this line

    ```set statusline+=\{…\}%3{codeium#GetStatusString()}  " codeium status```

      If this is not disabled before codeium.vim is uninstalled, vim will freeze
      on startup.  (you'll have to edit .vimrc with an alternative editor,and/
      or disable loading of .vimrc then comment the above line indicated)
    * remove codeium.vim from $HOME/.vim/pack:
    ```rm -rf ~/.vim/pack/Exafunction```

  * installs following plugins:
    * [ALE](https://github.com/dense-analysis/ale)
    * [codeium](https://github.com/Exafunction/codeium.vim)
    * [fzf.vim](https://github.com/junegunn/fzf.vim)
    * ~~[Github copilot](https://github.com/github/copilot.vim)~~ (use codeium)
    * [hashivim](https://github.com/hashivim/vim-terraform)
    * [indentLine](https://github.com/Yggdroot/indentLine)
    * [monokai colorscheme](https://github.com/sickill/vim-monokai)
    * [nerdtree](https://github.com/preservim/nerdtree)
    * [tagbar](https://github.com/preservim/tagbar)
    * [vim-commentary](https://github.com/tpope/vim-commentary)
    * [vim-unimpaired](https://github.com/tpope/vim-unimpaired)
    * [vimwiki](https://github.com/vimwiki/vimwiki)
    * [personal/custom .vimrc](https://github.com/richlamdev/ansible-desktop-ubuntu/blob/master/roles/vim/files/.vimrc)


## System Updates

The commands used to keep your system up to date are:

1. `sudo apt update && sudo apt upgrade -y`
2. `sudo apt autoremove -y` (not really an update, but removes old packages)
3. `sudo snap refresh`*

*while snap package mangement is controversial - tradeoff of manual updates
vs. convenience...


## Idempotency

The majority of this playbook is idempotent.  Minimal use of Ansible shell or
command is used.


## Scripts

1. gen_ssh_keys.sh - generates a new SSH key pair for localhost and copies
the public key to ~/.ssh/authorized_keys.

2. check_ssh_auth.sh - checks for SSH authentication methods against a host
Eg: `./check_ssh_auth.sh localhost`


## Random Notes, General Information & Considerations

1. For further information regarding command line switches and arguments above,
please see the [Ansible documentation](https://docs.ansible.com/ansible/latest/cli/ansible-playbook.html),
alternatively read my [ansible-misc github repo](https://github.com/richlamdev/ansible-misc.git)

2. Review the base role for potential unwanted software installation/
configuration.  The majority of the software within the base role is software
available via the default apt repositories.  Other software are some git repos,
keychron keyboard setup, and screen blanking short-cut key enablement.
Furthermore the roles env and vim are personal preferences.

3. Appropriate GPG keys are added to /usr/share/keyrings/ folder for third
party apt packages, and referenced within repos, per deprecation of apt-key as
of Ubuntu 22.04.

4. The organization of this ansible repo has become a little messier than
preferred.  TODO: Clean it up to be more organized / readable / reusable.
