#!/bin/bash

echo -e "\031[0;33m"
echo " :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::";
echo "  Jangan lupa berdoa sebelum memulai !...                             ";
echo "  Twitter : https://twitter.com/dwentzart                             ";
echo "  Github  : https://github.com/Whalealert                             ";
echo "    -----------–------------------------------------                  ";
echo "         .........SEMOGA MEMBANTU ...........                         ";
echo " :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::";
echo -e "\e[0m"

sleep 2

# set vars
if [ ! $NODENAME ]; then
	read -p "Enter node name: " NODENAME
	echo 'export NODENAME='$NODENAME >> $HOME/.bash_profile
fi
TERP_PORT=32
if [ ! $WALLET ]; then
	echo "export WALLET=wallet" >> $HOME/.bash_profile
fi
echo "export TERP_CHAIN_ID=athena-2" >> $HOME/.bash_profile
echo "export TERP_PORT=${TERP_PORT}" >> $HOME/.bash_profile
source $HOME/.bash_profile

echo '================================================='
echo -e "moniker : \e[1m\e[32m$NODENAME\e[0m"
echo -e "wallet  : \e[1m\e[32m$WALLET\e[0m"
echo -e "chain-id: \e[1m\e[32m$TERP_CHAIN_ID\e[0m"
echo '================================================='
sleep 2

echo -e "\e[1m\e[32m1. Updating packages... \e[0m" && sleep 1
# update
sudo apt update && sudo apt upgrade -y

echo -e "\e[1m\e[32m2. Installing dependencies... \e[0m" && sleep 1
# packages
sudo apt install curl build-essential git wget jq make gcc tmux chrony -y

# install go
if ! [ -x "$(command -v go)" ]; then
  ver="1.18.2"
  cd $HOME
  wget "https://golang.org/dl/go$ver.linux-amd64.tar.gz"
  sudo rm -rf /usr/local/go
  sudo tar -C /usr/local -xzf "go$ver.linux-amd64.tar.gz"
  rm "go$ver.linux-amd64.tar.gz"
  echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> ~/.bash_profile
  source ~/.bash_profile
fi

echo -e "\e[1m\e[32m3. Downloading and building binaries... \e[0m" && sleep 1
# download binary
cd $HOME
git clone https://github.com/terpnetwork/terp-core.git
cd terp-core
git checkout v0.1.2
make install

# config
terpd config chain-id $TERP_CHAIN_ID
terpd config keyring-backend test
terpd config node tcp://localhost:${TERP_PORT}657

# init
terpd init $NODENAME --chain-id $TERP_CHAIN_ID

# download genesis and addrbook
wget -qO $HOME/.terp/config/genesis.json "https://raw.githubusercontent.com/terpnetwork/test-net/master/athena-2/genesis.json"


# set peers and seeds
SEEDS=""
peers="15f5bc75be9746fd1f712ca046502cae8a0f6ce7@terp-testnet.nodejumper.io:26656,7e5c0b9384a1b9636f1c670d5dc91ba4721ab1ca@23.88.53.28:36656"
sed -i -e 's|^seeds *=.*|seeds = "'$seeds'"|; s|^persistent_peers *=.*|persistent_peers = "'$peers'"|' $HOME/.terp/config/config.toml

# set custom ports
sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${TERP_PORT}658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${TERP_PORT}657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${TERP_PORT}060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${TERP_PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${TERP_PORT}660\"%" $HOME/.terp/config/config.toml
sed -i.bak -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:${TERP_PORT}317\"%; s%^address = \":8080\"%address = \":${TERP_PORT}080\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:${TERP_PORT}090\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${TERP_PORT}091\"%" $HOME/.terp/config/app.toml

# config pruning
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="50"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/.terp/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/.terp/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/.terp/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/.terp/config/app.toml

# set minimum gas price and timeout commit
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0.001upersyx\"/" $HOME/.terp/config/app.toml

# enable prometheus
sed -i -e "s/prometheus = false/prometheus = true/" $HOME/.terp/config/config.toml

# reset
terpd tendermint unsafe-reset-all --home $HOME/.terp

echo -e "\e[1m\e[32m4. Starting service... \e[0m" && sleep 1
# create service
sudo tee /etc/systemd/system/terpd.service > /dev/null <<EOF
[Unit]
Description=terp
After=network-online.target

[Service]
User=$USER
ExecStart=$(which terpd) start --home $HOME/.terp
Restart=on-failure
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF

# start service
sudo systemctl daemon-reload
sudo systemctl enable terpd
sudo systemctl restart terpd

echo '=============== SETUP FINISHED ==================='
echo -e 'To check logs: \e[1m\e[32mjournalctl -u terpd -f -o cat\e[0m'
echo -e "To check sync status: \e[1m\e[32mcurl -s localhost:${TERP_PORT}657/status | jq .result.sync_info\e[0m"
