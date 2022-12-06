FROM registry.gitlab.iitsp.com/allworldit/docker/alpine/v3.17:latest

ARG VERSION_INFO=
LABEL maintainer="Nigel Kukard <nkukard@lbsd.net>"

RUN set -ex; \
	true "Openssh and rsync"; \
	apk add --no-cache openssh rsync; \
	true "Versioning"; \
	if [ -n "$VERSION_INFO" ]; then echo "$VERSION_INFO" >> /.VERSION_INFO; fi; \
	true "Cleanup"; \
	rm -f /var/cache/apk/*


RUN set -ex; \
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
COPY etc/supervisor/conf.d/openssh.conf /etc/supervisor/conf.d/openssh.conf
COPY etc/ssh/sshd_config /etc/ssh/sshd_config
COPY init.d/60-push.sh /docker-entrypoint-init.d/60-push.sh
COPY pre-init-tests.d/60-push.sh /docker-entrypoint-pre-init-tests.d/60-push.sh
COPY tests.d/60-push.sh /docker-entrypoint-tests.d/60-push.sh
RUN set -ex; \
		mkdir /etc/openssh.conf.d; \
		chown root:root \
			/etc/ssh/sshd_config \
			/etc/supervisor/conf.d/openssh.conf \
			/docker-entrypoint-init.d/60-push.sh \
			/docker-entrypoint-pre-init-tests.d/60-push.sh \
			/docker-entrypoint-tests.d/60-push.sh; \
		chmod 0644 \
			/etc/ssh/sshd_config \
			/etc/supervisor/conf.d/openssh.conf; \
		chmod 0755 \
			/docker-entrypoint-init.d/60-push.sh \
			/docker-entrypoint-tests.d/60-push.sh

VOLUME ["/data"]
VOLUME ["/etc/ssh/keys"]

EXPOSE 22

