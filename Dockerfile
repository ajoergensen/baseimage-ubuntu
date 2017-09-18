FROM phusion/baseimage:latest

ARG BUILD_DATE
ARG VCS_REF
LABEL org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.vcs-url="https://github.com/ajoergensen/baseimage-ubuntu.git" \
      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.schema-version="1.0.0-rc1"

# Set correct environment variables.
ENV TZ=Europe/Copenhagen LANG=en_US.UTF-8 LANGUAGE=en_US.UTF-8 LC_ALL=en_US.UTF-8 DISABLE_SSH=1 
ENV DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true

# Ubuntu configuration
ADD files/sources.list /etc/apt/sources.list
ADD files/preseed.txt /tmp/preseed.txt
RUN \
	echo 'LANG="en_US.UTF-8"\nLANGUAGE="en_US:en"' > /etc/default/locale && \
	debconf-set-selections /tmp/preseed.txt && \
	dpkg-reconfigure locales && \
        apt-get -q update && \
	apt-get -qy --force-yes dist-upgrade && \
	apt-get -y install sudo apt-transport-https tzdata wget syslog-ng-core curl ca-certificates ssmtp perl-modules-5.22 xz-utils && \
	ln -fs /usr/share/zoneinfo/Europe/Copenhagen /etc/localtime && \
	dpkg-reconfigure -f noninteractive tzdata && \
	groupadd -r syslog && \
	useradd -u 911 -s /bin/false app && \
	groupmod -g 911 app && \
	usermod -G users app && \
	mkdir -p /app /config /defaults && \
	apt-get clean && \
	rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /etc/my_init.d/00_regen_ssh_host_keys.sh

COPY root/ /

RUN chmod +x -v /etc/my_init.d/*.sh /usr/local/sbin/*
