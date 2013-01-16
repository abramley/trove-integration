#!/usr/bin/env bash

# Adds user to the sudoers file so they can do everything w/o a pass
# Some binaries might be under /sbin or /usr/sbin, so make sure sudo will
# see them by forcing PATH
$TEMPFILE=`mktemp`
echo "GUEST_USERNAME ALL=(ALL) NOPASSWD:ALL" > $TEMPFILE
chmod 0440 $TEMPFILE
sudo chown root:root $TEMPFILE
sudo mv $TEMPFILE /etc/sudoers.d/60_reddwarf_guest

# Copies all the reddwarf code to the guest image
sudo -u GUEST_USERNAME rsync -e'ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no' -avz --exclude='.*' HOST_USERNAME@10.0.0.1:PATH_REDDWARF/ /home/GUEST_USERNAME/reddwarf

# Do an apt-get update since its SUPER slow first time
apt-get update

# Add extras which is _only_ in pip.....
pip install extras

# Starts the reddwarf guestagent (using the upstart script)
service reddwarf-guest start
