#!/bin/bash
set -e
set -x

github_username=$(echo $GITHUB_ACTOR|  tr '[:upper:]' '[:lower:]')

dnf -y install dnf-plugins-core
dnf -y copr enable @CoreOS/continuous
dnf -y install git docker skopeo rpm-ostree-2021.14.79.ga30dec3f-1.fc35.x86_64

docker login ghcr.io -u $GITHUB_ACTOR -p $GITHUB_TOKEN

rpm-ostree --version

pushd /tmp/container

git clone -b f35 https://pagure.io/workstation-ostree-config

pushd workstation-ostree-config

mkdir -p repo cache && ostree --repo=repo init --mode=archive
rpm-ostree compose tree --repo=repo --cachedir=cache fedora-silverblue.yaml
ostree --verbose summary --repo=repo --update

rpm-ostree ex-container encapsulate \
	--repo=repo \
	fedora/35/x86_64/silverblue \
	docker://ghcr.io/$github_username/fedora-silverblue:35
