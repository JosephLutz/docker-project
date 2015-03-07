apt-get update && \
DEBIAN_FRONTEND=noninteractive apt-get install --yes subversion &&\
DEBIAN_FRONTEND=noninteractive apt-get install --yes websvn && \
apt-get clean && \
rm -rf /var/lib/apt/lists/*