source config.sh

sudo docker pull debian:8
sudo docker pull osixia/phpldapadmin

move_latest_to_tag() {
    local image_name
    image_name=${1}
    sudo true
    sudo docker inspect "${image_name}:latest" &> /dev/null
    if sudo docker inspect "docker.io/${image_name}:${TAG}" &> /dev/null
    then
        # This is to get around the Issue with the CentOS changes to the Docker package
        sudo docker rmi "docker.io/${image_name}:${TAG}"
    fi
    if sudo docker inspect "${image_name}:${TAG}" &> /dev/null
    then
        sudo docker rmi "${image_name}:${TAG}"
    fi
    sudo docker tag "${image_name}:latest" "${image_name}:${TAG}"
    sudo docker rmi "${image_name}:latest"
}

build_image() {
    local image_name
    image_name=${1}
    printf '***************************************\n'
    printf 'Building image : %s\n' "${image_name}"
    printf '***************************************\n'
    sudo docker build --rm=true --tag="${image_name}" ./$(get_docker_dir ${image_name})
    move_latest_to_tag "${image_name}"
}


build_image ${NAME_LDAP_IMAGE}

sudo docker inspect ${NAME_LDAP_DV} &> /dev/null || \
sudo docker run -ti --name "${NAME_LDAP_DV}" --entrypoint="/bin/true" ${NAME_LDAP_IMAGE}:${TAG}

sudo docker run -ti --rm --volumes-from "${NAME_LDAP_DV}" ${NAME_LDAP_IMAGE}:${TAG} /bin/bash
#	apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install --yes --no-install-recommends vim slapd ldap-utils openssl ca-certificates
#	cd /etc
#	tar -xaf ldap.tar.gz
#	echo 'BASE    dc=novatech' >> /etc/ldap/ldap.conf
#	echo 'URI     ldap://ldap.novatech-llc.com' >> /etc/ldap/ldap.conf
#	dpkg-reconfigure slapd
#		No
#		novatech
#		novatech
#		novatech
#		novatech
#		HDB
#		Yes
#		Yes
#		No

docker run -ti --rm --volumes-from "DV_ldap" novatechweb/ldap:current ldapsearch -x -h localhost

ldapsearch -x -h ldap.novatech-llc.com

go.start.sh ldap

docker run --name "phpldapadmin" -P -p 172.16.71.110:80:80 -e HTTPS=false -e LDAP_HOSTS=ldap -d --link ldap:ldap osixia/phpldapadmin
