#!/bin/bash

echo "TESTS: Openssh connectivity..."
OUT_V4_22=$(socat -T2 - "TCP:127.0.0.1:22,end-close" < /dev/null)
if ! grep 'SSH-2.0-OpenSSH' <<< "$OUT_V4_22"; then
	echo "CHECK FAILED (openssh): Check IPv4 port 22 works"
	false
fi

echo "TESTS: Listing of incoming module..."
if ! rsync -e 'ssh -o StrictHostKeyChecking=No -i /root/testsshkey' -L push@localhost::incoming; then
	echo "CHECK FAILED: Failed to list incoming module"
	false
fi

echo test > /root/test.txt
echo "TESTS: Upload file..."
if ! rsync -e 'ssh -o StrictHostKeyChecking=No -i /root/testsshkey' /root/test.txt push@localhost::incoming/; then
	echo "CHECK FAILED: Failed to upload file to incoming module"
	false
fi

echo "TESTS: Compare uploaded file..."
if ! diff /root/test.txt /data/test.txt; then
	echo "CHECK FAILED: Failed compare of uploaded test.txt file"
	false
fi

