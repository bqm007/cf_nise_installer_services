#!/bin/bash -ex

NISE_IP_ADDRESS=${NISE_IP_ADDRESS:-192.168.10.11}
VAGRANT_MEMORY=${VAGRANT_MEMORY:-4096}

NISE_IP_ADDRESS=${NISE_IP_ADDRESS} ./common/launch_nsie_bosh.sh

BRIDGE_OPTION=
if [ ${NISE_IP_ADDRESS} != "192.168.10.11" ]; then
    BRIDGE_OPTION="--bridge --address=${NISE_IP_ADDRESS}"
else
    BRIDGE_OPTION="--address=${NISE_IP_ADDRESS}"
fi

nise-bosh-vagrant ./cf-services-contrib-release --manifest ./manifests/deploy.yml --memory ${VAGRANT_MEMORY} --postinstall ./vagrant/postinstall.sh --install ${BRIDGE_OPTION}

# Reboot VM once to reload kernel
(
    cd cf-services-contrib-release
    vagrant ssh -c "sudo reboot" | true
    sleep 10
    vagrant ssh -c "sudo /etc/init.d/vboxadd setup"
    vagrant halt
    sleep 10
    vagrant up
)
