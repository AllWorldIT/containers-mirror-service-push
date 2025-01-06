#!/bin/bash
# Copyright (c) 2022-2025, AllWorldIT.
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


fdc_test_start mirror-service-push "OpenSSH connectivity using IPv4..."
OUT_V4_22=$(socat -T2 - "TCP:127.0.0.1:22,end-close" < /dev/null)
if ! grep 'SSH-2.0-OpenSSH' <<< "$OUT_V4_22"; then
	fdc_test_fail mirror-service-push "Check IPv4 port 22 works"
	false
fi
fdc_test_pass mirror-service-push "OpenSSH reachable over IPv4"


fdc_test_start mirror-service-push "Check listing of 'incoming' using IPv4..."
if ! rsync --ipv4 -e 'ssh -o StrictHostKeyChecking=No -i /root/testsshkey' -L push@localhost::incoming; then
	fdc_test_fail mirror-service-push "Failed to list 'incoming' module using IPv4"
	false
fi
fdc_test_pass mirror-service-push "List of 'incoming' module using IPv4 worked"


fdc_test_start mirror-service-push "Testing file upload to 'incoming' module using IPv4"
echo test4 > /root/test.txt
if ! rsync --ipv4 -e 'ssh -o StrictHostKeyChecking=No -i /root/testsshkey' /root/test.txt push@localhost::incoming/; then
	fdc_test_fail mirror-service-push "Failed to push file to 'incoming' module using IPv4"
	false
fi
fdc_test_pass mirror-service-push "Upload of file to 'incoming' module using IPv4 worked"


fdc_test_start mirror-service-push "Compare uploaded file to test file using IPv4..."
if ! diff /root/test.txt /data/test.txt; then
	fdc_test_fail mirror-service-push "Compare of uploaded file failed using IPv4"
	false
fi
fdc_test_pass mirror-service-push "Uploaded file matches test file using IPv4"


# Return if we don't have IPv6 support
if [ -z "$(ip -6 route show default)" ]; then
	fdc_test_alert mirror-service-push "Not running IPv6 tests due to no IPv6 default route"
	return
fi


fdc_test_start mirror-service-push "OpenSSH connectivity using IPv6..."
OUT_V6_22=$(socat -T2 - "TCP:[::1]:22,end-close" < /dev/null)
if ! grep 'SSH-2.0-OpenSSH' <<< "$OUT_V6_22"; then
	fdc_test_fail mirror-service-push "Check IPv6 port 22 works"
	false
fi
fdc_test_pass mirror-service-push "OpenSSH reachable over IPv6"


fdc_test_start mirror-service-push "Check listing of 'incoming' using IPv6..."
if ! rsync --ipv6 -e 'ssh -o StrictHostKeyChecking=No -i /root/testsshkey' -L push@localhost::incoming; then
	fdc_test_fail mirror-service-push "Failed to list 'incoming' module using IPv6"
	false
fi
fdc_test_pass mirror-service-push "List of 'incoming' module using IPv6 worked"


fdc_test_start mirror-service-push "Testing file upload to 'incoming' module using IPv6"
echo test6 > /root/test6.txt
if ! rsync --ipv6 -e 'ssh -o StrictHostKeyChecking=No -i /root/testsshkey' /root/test6.txt push@localhost::incoming/; then
	fdc_test_fail mirror-service-push "Failed to push file to 'incoming' module using IPv6"
	false
fi
fdc_test_pass mirror-service-push "Upload of file to 'incoming' module using IPv6 worked"


fdc_test_start mirror-service-push "Compare uploaded file to test file using IPv6..."
if ! diff /root/test6.txt /data/test6.txt; then
	fdc_test_fail mirror-service-push "Compare of uploaded file failed using IPv6"
	false
fi
fdc_test_pass mirror-service-push "Uploaded file matches test file using IPv6"

