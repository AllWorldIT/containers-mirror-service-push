#!/bin/bash
# Copyright (c) 2022-2023, AllWorldIT.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to
# deal in the Software without restriction, including without limitation the
# rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
# sell copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
# IN THE SOFTWARE.


fdc_notice "Initializing Mirror Service Push settings"

# Check if we have host keys
if [ ! -e /etc/ssh/keys/ssh_host_ed25519_key ]; then
	fdc_notice "Generating new Mirror Service Push SSH host key..."
	ssh-keygen -q -N "" -t ed25519 -f /etc/ssh/keys/ssh_host_ed25519_key
fi
cp /etc/ssh/keys/ssh_host_ed25519_key{,.pub} /etc/ssh/
chmod 0600 /etc/ssh/ssh_host_ed25519_key
chmod 0644 /etc/ssh/ssh_host_ed25519_key.pub
chown root:root /etc/ssh/ssh_host_ed25519_key{,.pub}

# Exit if we have no config
if [ -z "$MIRROR_PUSH_CONFIG" ]; then
	fdc_error "No Mirror Push Service has no 'MIRROR_PUSH_CONFIG'"
	false
fi

# Setup keys
echo "$MIRROR_PUSH_CONFIG" | grep ssh-ed25519 | while read -r aline; do
	conf_file=/home/push/$(cut -d' ' -f3 <<< "$aline").conf
	pid_file=/home/push/$(cut -d' ' -f3 <<< "$aline").pid
	lock_file=/home/push/$(cut -d' ' -f3 <<< "$aline").lock
	ssh_key=$(cut -d' ' -f1-3 <<< "$aline")
	upload_path=$(cut -d' ' -f4- <<< "$aline")

	if [ -z "$conf_file" ]; then
		fdc_error "Invalid Mirror Push Service config line: $aline"
		continue
	fi
	if [ -z "$ssh_key" ]; then
		fdc_error "Invalid Mirror Push Service ssh key: $aline"
		continue
	fi
	if [ -z "$upload_path" ]; then
		fdc_error "Invalid Mirror Push Service upload path: $aline"
		continue
	fi

	fdc_info "Mirror Push Service key config: $ssh_key"
	fdc_info "  - conf_file = $conf_file"
	fdc_info "  - upload_path = $upload_path"

	# Output authorized keys
	cat <<EOF >> /home/push/.ssh/authorized_keys
command="rsync --config=$conf_file --server --daemon .",no-agent-forwarding,no-port-forwarding,no-pty,no-user-rc,no-X11-forwarding $ssh_key
EOF
	# Output rsyncd config file
	cat <<EOF > "$conf_file"
use chroot = no
max connections = 1
pid file = $pid_file
lock file = $lock_file

[incoming]
	path = $upload_path
	read only = false
	munge symlinks = false
EOF
	# Set permissions on config file
	chown root:root "$conf_file"
	chmod 0644 "$conf_file"
done

# Set permissions on authorized keys file
chown push:push /home/push/.ssh/authorized_keys
chmod 0600 /home/push/.ssh/authorized_keys
