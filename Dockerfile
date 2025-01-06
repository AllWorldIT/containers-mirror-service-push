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


FROM registry.conarx.tech/containers/alpine/3.21


ARG VERSION_INFO=

LABEL org.opencontainers.image.authors   = "Nigel Kukard <nkukard@conarx.tech>"
LABEL org.opencontainers.image.version   = "3.21"
LABEL org.opencontainers.image.base.name = "registry.conarx.tech/containers/alpine/3.21"



RUN set -eux; \
	true "Openssh and rsync"; \
	apk add --no-cache \
		openssh rsync; \
	true "Cleanup"; \
	rm -f /var/cache/apk/*


RUN set -eux; \
	true "Setup push user"; \
	addgroup -g 1001 push; \
	adduser -u 1001 -D -h /home/push -G push -g "Push user" push; \
	chmod 0700 /home/push; \
	mkdir /home/push/.ssh; \
	chmod 0500 /home/push/.ssh; \
	chown push:push /home/push/.ssh; \
	true "Unlocking user account"; \
	sed -ie 's/^push:!:/push:*:/' /etc/shadow; \
	true "Setup SSH access group"; \
	addgroup -S rsyncssh; \
	adduser push rsyncssh; \
	true "Setup data directory"; \
	mkdir -p /data; \
	chown push:push /data


# Openssh
COPY etc/supervisor/conf.d/openssh.conf /etc/supervisor/conf.d
COPY etc/ssh/sshd_config /etc/ssh
COPY usr/local/share/flexible-docker-containers/init.d/42-mirror-service-push.sh /usr/local/share/flexible-docker-containers/init.d
COPY usr/local/share/flexible-docker-containers/pre-init-tests.d/42-mirror-service-push.sh /usr/local/share/flexible-docker-containers/pre-init-tests.d
COPY usr/local/share/flexible-docker-containers/tests.d/42-mirror-service-push.sh /usr/local/share/flexible-docker-containers/tests.d
COPY usr/local/share/flexible-docker-containers/healthcheck.d/42-mirror-service-push.sh /usr/local/share/flexible-docker-containers/healthcheck.d
RUN set -eux; \
	true "Flexible Docker Containers"; \
	if [ -n "$VERSION_INFO" ]; then echo "$VERSION_INFO" >> /.VERSION_INFO; fi; \
	true "Permissions"; \
	fdc set-perms


VOLUME ["/data", "/etc/ssh/keys"]


EXPOSE 22
