set -e
apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install --yes apache2-utils
DEBIAN_FRONTEND=noninteractive apt-get install --yes libapache2-svn
DEBIAN_FRONTEND=noninteractive apt-get install --yes enscript
DEBIAN_FRONTEND=noninteractive apt-get install --yes websvn
apt-get clean
rm -rf /var/lib/apt/lists/*