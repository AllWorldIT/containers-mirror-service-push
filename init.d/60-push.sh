#!/bin/sh

# Check if we have host keys
if [ ! -e /etc/ssh/keys/ssh_host_ed25519_key ]; then
	ssh-keygen -q -N "" -t ed25519 -f /etc/ssh/keys/ssh_host_ed25519_key
fi
cp /etc/ssh/keys/ssh_host_ed25519_key{,.pub} /etc/ssh/
chmod 0600 /etc/ssh/ssh_host_ed25519_key
chmod 0644 /etc/ssh/ssh_host_ed25519_key.pub
chown root:root /etc/ssh/ssh_host_ed25519_key{,.pub}

# Exit if we have no config
if [ -z "$MIRROR_PUSH_CONFIG" ]; then
	echo "WARNING: No MIRROR_PUSH_CONFIG"
	exit
fi

# Setup keys
echo "$MIRROR_PUSH_CONFIG" | grep ssh-ed25519 | while read aline; do
	conf_file=/home/push/$(echo "$aline" | cut -d' ' -f3).conf
	pid_file=/home/push/$(echo "$aline" | cut -d' ' -f3).pid
	lock_file=/home/push/$(echo "$aline" | cut -d' ' -f3).lock
	ssh_key=$(echo "$aline" | cut -d' ' -f1-3)
	upload_path=$(echo "$aline" | cut -d' ' -f4-)

	if [ -z "$conf_file" ]; then
		echo "ERROR! Invalid conf_file: $aline"
		continue
	fi
	if [ -z "$ssh_key" ]; then
		echo "ERROR! Invalid ssh_key: $aline"
		continue
	fi
	if [ -z "$upload_path" ]; then
		echo "ERROR! Invalid upload_path: $aline"
		continue
	fi

	echo "Key config: $ssh_key"
	echo "- conf_file = $conf_file"
	echo "- upload_path = $upload_path"

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

