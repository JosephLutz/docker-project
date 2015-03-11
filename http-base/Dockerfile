#
# WebSVN (sshd DEBUG) Docker container
#
# Version 0.0

FROM ubuntu:14.04
MAINTAINER Joseph Lutz <Joseph.Lutz@novatechweb.com>

# copy over scripts
COPY ["./install.sh", "/usr/local/bin/"]

# install the needed packages
RUN ["/bin/bash", "/usr/local/bin/install.sh"]

CMD ["/bin/bash"]
