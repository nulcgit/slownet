#!/usr/bin/env bash

cd "$(dirname "$0")"
export SLOWNET="$PWD"
mkdir -p bin temp apps data/share/log
(echo -e "$(date -u) SlowNet installation started.") >> $PWD/data/log.txt
echo PATH="$PATH:/home/$USER/.local/bin:$PWD/bin" | sudo tee /etc/environment
echo SLOWNET="$PWD" | sudo tee -a /etc/environment
export PATH="$PATH:/home/$USER/.local/bin:$PWD/bin"
sudo apt update
sudo DEBIAN_FRONTEND=noninteractive apt full-upgrade -yq
sudo DEBIAN_FRONTEND=noninteractive apt install -y docker.io docker-compose-v2 build-essential python3-dev python3-pip python3-venv tmux cron nncp yggdrasil
sudo usermod -aG docker $USER
sudo systemctl restart docker
python3 -m venv venv
source venv/bin/activate
pip install reader[cli] -q
sudo apt install --reinstall iputils-ping

yggdrasil -genconf | sudo tee /etc/yggdrasil/yggdrasil.conf
sudo sed -i "s/ Peers\: \[\]/ Peers: \[\n    quic\:\/\/ip4.01.ekb.ru.dioni.su\:9002\?priority=0 \n  \]/g" /etc/yggdrasil/yggdrasil.conf
sudo sed -i "s/ NodeInfo\: {}/ NodeInfo\: \{\n    name: slownet$(date -u +"%Y%m%d%H%M%S")\n  \}/g" /etc/yggdrasil/yggdrasil.conf
sudo systemctl daemon-reload
sudo systemctl enable yggdrasil
sudo systemctl restart yggdrasil

nncp-cfgnew | sudo tee /etc/nncp.hjson
sudo cp /usr/share/doc/nncp/examples/nncp-daemon.service /etc/systemd/system
sudo sed -i "s/mcd-send: {.*: 10}/mcd-send: {.*: 600}/g" /etc/nncp.hjson
sudo systemctl daemon-reload
sudo systemctl enable nncp-daemon
sudo systemctl restart nncp-daemon

echo -e "$(sudo crontab -l)\n@reboot echo \"\$(date -u) System is rebooted\" >> $PWD/data/log.txt\n* * * * * su $USER -c \"bash $PWD/bin/cron.sh\"" | sudo crontab -

sleep 9
cd "$(dirname "$0")"
rm -rf temp
mkdir temp
ping -6 -c 5 21e:a51c:885b:7db0:166e:927:98cd:d186
sudo reboot
