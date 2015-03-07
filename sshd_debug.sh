apt-get update && \
DEBIAN_FRONTEND=noninteractive apt-get install --yes openssh-server && \
apt-get clean && \
rm -rf /var/lib/apt/lists/* && \
mkdir /var/run/sshd && \
echo 'root:novatech' | chpasswd && \
sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd      # SSH login fix. Otherwise user is kicked off after login