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
LOYAL_PORT=31
if [ ! $WALLET ]; then
	echo "export WALLET=wallet" >> $HOME/.bash_profile
fi
echo "export LOYAL_CHAIN_ID=loyal-1" >> $HOME/.bash_profile
echo "export LOYAL_PORT=${LOYAL_PORT}" >> $HOME/.bash_profile
source $HOME/.bash_profile

echo '================================================='
echo -e "moniker : \e[1m\e[32m$NODENAME\e[0m"
echo -e "wallet  : \e[1m\e[32m$WALLET\e[0m"
echo -e "chain-id: \e[1m\e[32m$LOYAL_CHAIN_ID\e[0m"
echo '================================================='
sleep 2

echo -e "\e[1m\e[32m1. Updating packages... \e[0m" && sleep 1
# update
sudo apt update && sudo apt upgrade -y

echo -e "\e[1m\e[32m2. Installing dependencies... \e[0m" && sleep 1
# packages
sudo apt install curl build-essential git wget jq make gcc tmux chrony -y

# install go
ver="1.19" && \
wget "https://golang.org/dl/go$ver.linux-amd64.tar.gz" && \
sudo rm -rf /usr/local/go && \
sudo tar -C /usr/local -xzf "go$ver.linux-amd64.tar.gz" && \
rm "go$ver.linux-amd64.tar.gz" && \
echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> $HOME/.bash_profile && \
source $HOME/.bash_profile && \
go version

echo -e "\e[1m\e[32m3. Downloading and building binaries... \e[0m" && sleep 1
# download binary
cd $HOME
wget https://github.com/LoyalLabs/loyal/releases/download/v0.25.1/loyal_v0.25.1_linux_amd64.tar.gz
tar xzf loyal_v0.25.1_linux_amd64.tar.gz
chmod 775 loyald
sudo mv loyald /usr/local/bin/
sudo rm loyal_v0.25.1_linux_amd64.tar.gz


# config
loyald config chain-id $LOYAL_CHAIN_ID
loyald config keyring-backend test
loyald config node tcp://localhost:${LOYAL_PORT}657

# init
loyald init $NODENAME --chain-id $LOYAL_CHAIN_ID

# download genesis and addrbook
wget -qO $HOME/.loyal/config/genesis.json "https://raw.githubusercontent.com/LoyalLabs/net/main/mainnet/genesis.json"

# set peers and seeds
PEERS=5d08d10e66b349f2287605d9a110a6489130ace0@159.203.46.245:2566,7490c272d1c9db40b7b9b61b0df3bb4365cb63a6@54.80.32.192:26656,926b0b31e7b5f1b6a326fbb37f514cc37c31ac2d@149.102.144.153:2566,607dbee191f06d9479d7ae8f9fc5de75ca840d6f@185.215.167.227:31656,d53900056b6c5c0a753286636076b05b8138a3cf@161.35.126.124:2566,0f47d3c784ab55288a780201a3f38066f702fe3a@135.181.176.109:48656,2c3b32ca5b5799d31115c10fa0bb75718f973983@185.177.116.6:2566,4dee73af0dfcf44523e82b7b20fcb48ffea5138c@162.19.93.127:26656,f15a7901ea4a3b318ebc196915b72c3cf54dc6d6@18.236.110.150:26656,0fa9063dc4869882ff0073f6566d8cf79c8e81cd@4.236.171.134:2566,a19b19f09084e9f1579243a5613efde8ae5aa946@65.21.199.148:26624,461ddc6d315e933d5cdb0d7f6b8d413f11539d0b@159.65.155.162:2566,d0e0ca1af09674f71101658f646175b4e17bc5ca@65.20.66.44:2566,dbb485929f41f6cd96dc7abccb65f0f9d73180a1@185.250.36.53:2566,056011f128eb099993db18c4fcdf66d19007a1e8@20.255.163.130:2566,fe976760ee833422f4efd72277c4157c92e57fff@74.208.187.2:2566,99b577e46e21f2b86922c9e7a308a57cf9a6db81@194.163.133.221:2566,83968de955aeff3a484edf7c258cee4f1830b237@20.232.44.163:2566,1adb7ae663df538cea1069627dca98cccc6f10b3@185.208.207.45:2566,436a58f8113421d6c7bb0dd84a80e88c14e42602@74.208.28.77:2566,8a2665d42cb516d2dacfa7ce8f4650eb87589077@185.182.184.27:2566,dfa87287bf12faf2d20e27e98c3feffa0c1c9aba@144.126.134.126:26656,e376b294be27013038aa0753113e5980c8308813@149.102.129.56:2566,2d235a3110b3973469681df1e7c470b51cee6334@161.35.160.28:2566,e397a9fc169e7e6721a94f4fd43e0e036aeca2eb@20.163.88.92:2566,fd9644ac11968928dabcb624cbbe1ddbdd01a57b@165.22.49.102:2566,dc5b20991c29d676052c649ee5ee5d93e47bf997@167.99.73.177:2566,9771ae4427617b12a49680419a4cb0e15e03a4b4@185.188.249.173:2566,2b9f555e4e0fe197664ed11cd7e1a05c020e5583@178.18.247.240:2566,c9b5c9ac6758bcf5dcddd108d3fc5f7805a70f71@217.160.64.238:2566,42dde3808998a521d606a0a431d22dfd22cf4f8d@185.208.207.157:2566,49c0f05a1a47f4d020d3e8c8c7e67f03e44fa5d7@198.71.61.239:2566,15070caeafb62d2c0f27363890669cd702946d9f@161.35.60.67:2566,14f43f2c814ac0a6546956e53a08325fca5780b0@108.175.1.50:2566,40b518269157227951f6da8c4386f655e76f3239@161.97.169.185:2566,33522141b1b448be235f43ea4b929b1123acc4e5@141.95.20.161:2566,e1f5095129734c057236244a3ce10a081c8fc808@161.35.16.250:2566,e2c8d87890eba66a7c591e4a9bc8be241bf06120@108.175.1.149:2566,622c34c0435bf64c1a1556da92540dcc24dcb2a2@108.175.1.36:2566,47d3710a2c9dfb172d346c1f89ca969c68a49a0c@68.183.225.213:2566,b8b6f17a6fd4b69d198fa248e3105b93ea48d973@38.242.217.226:2566,4db7eaa882227c2e46e1b3afcca549a37011c949@206.189.107.87:2566,f630eb3d031148f656e8b56e60be95f09a0a2105@20.15.224.74:2566,c549997c59be890f12a9d86f89b3ccb9a858ee64@193.203.15.48:2566,ca5e26ae3a9472756ec29af1153ba6a74d01ff1e@20.25.133.141:2566,c7e692211ad4704d8329f6704b1156661b3407c7@138.68.164.146:2566,6b503c62b125e920d76971b52c1195d589d3fdf4@20.2.80.251:2566,14e6293dca9c9de5e0710b99c9ce0d29d9f1384b@38.242.229.50:2566,736f5608485eb0357e4f9cb9dcdce6577d8beffc@154.26.139.13:2566,367b20be2ac6e0a57d355a24e1d04ef8b0ff223e@159.223.203.127:2566,9fa6c4f5e0f3a73a668befcde07b7dfb3119b1c4@161.35.215.48:2566,6de4b209afffb810700ac5407656ac8d0acb5d33@149.102.155.26:2566,017a348d87179ad3bca1a154922bbca7f5a4abc3@194.163.167.147:2566,f38217783e4d091022c7f18e2233b6d57f708755@159.223.41.80:2566,b7b0caefa01734cff2fc893c77210e28c9c6013f@185.187.235.77:2566,45b081644640aced493058a125331493ceaf60dd@95.217.109.218:26656,06414580127ee1818477f137f2b77289fa8becc2@161.35.29.222:2566,af75c1cebd4e67e3e0062b4906679307bdc7c74c@178.128.159.18:2566,54d64f3030c9ced899159a10cbefa501cdd9c34b@38.242.130.204:2566,d36ea61b7cfe99c3c8180b36cd3a7f163d2e8247@167.172.80.202:656,7c99b523fea583e9b5d409f11818aaf1501834a3@149.102.135.139:2566,9d3e2a92c38d499ae0b891563728460d87495feb@198.71.61.63:2566,c015c4d94aaa6945712743e8c7a02c6bcc1205fb@178.18.251.91:2566,171ce849561394e6f8299a8b96adafe8ee381f26@146.190.74.36:2566,bc09e5bc8a7f5a49a9c50fee927e3227e5645dcc@108.175.1.164:2566,1aada59e8e6867d241c3a276dd96d3fd99c2a985@185.202.239.46:2566,7635a37f3eeba5e454719e4e34b152b3f48c2af1@154.26.132.174:2566,08762fcf6e4372653eb008637bec7fe732677b78@194.233.86.202:2566,10a57bd9f8a82db67577d12c986646b229b87839@20.168.59.62:2566,6ced2bc823d3db6824a32da9d77b323afdf4b4ec@154.26.139.98:2566,b00a09236eec12427ad91e4c505f69a301ad9f06@185.197.250.215:2566,a67339e8ad15d35fceac96bfb6d0ca75d9feaee2@161.97.141.127:2566,0b2113702b974e608a85ee73e1f94cbc5921fe85@149.102.129.254:2566,986f5488d5a5b51a5ebdd84f33d6459475bff6b4@109.123.252.4:2566,26c25bda862ce6fac0bc6d80d39f459731b75cf5@167.71.49.253:2566,35360f3024bf12cd2583719d19edfd7f720e2c22@185.197.250.134:2566,ce7c47621a76c35cb65f88bf677f674ccc1dd4b8@188.166.59.252:2566,8a3d3acce6459d77c238ea2b5f6d0a589437c800@159.65.94.227:2566,0ea3fe1139525d24db0ab4a447fb4c91dc17b6fd@161.97.170.61:2566,16b680ac5b3063eb6aaf34d8244ebefb4f853c8f@185.250.36.181:2566,c8946adbfadbf57a9b19cfe8c90cd860a8af83e5@147.182.199.144:2566,4d733f9cf3dd9edb79498309cf701f5cc3d13a88@68.183.184.192:2566,8292a767d30eded0feac55b51159becd72b72ccd@174.138.22.89:2566,2deb6d31df7c5b45c085e0fcd080216a329e4cb2@20.150.211.158:2566,ecd750c265d8f0854ab8dc99a1d982ad5e386715@142.132.201.130:26656,918ccbcc42b478acc9981d0cf812b391c4075d31@185.182.186.164:2566,aef8892b51d41058720d8055ea0727232c1127b9@109.123.251.26:2566,3a403bb556cfff0cdad14e3ad00cce5fdd290900@185.249.227.145:2566,8b39fdd933f661cc425cb4ae9a3c5cf501891c98@103.150.196.237:2566,5d01d9faba0a63efc0c65fad4ec97faae1e1679e@103.134.154.155:2566,2e3768f50014361c43e7e02a738cace6bb7ced5d@149.102.159.250:2566,694f8f64eefcbfaf4f71b5bb33e38122eb6cf47e@38.242.250.113:2566,b66ecdf36bb19a9af0460b3ae0901aece93ae006@44.211.18.98:26656
sed -i.bak -e "s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.loyal/config/config.toml

# set custom ports
sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${LOYAL_PORT}658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${LOYAL_PORT}657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${LOYAL_PORT}060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${LOYAL_PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${LOYAL_PORT}660\"%" $HOME/.loyal/config/config.toml
sed -i.bak -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:${LOYAL_PORT}317\"%; s%^address = \":8080\"%address = \":${LOYAL_PORT}080\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:${LOYAL_PORT}090\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${LOYAL_PORT}091\"%" $HOME/.loyal/config/app.toml

# config pruning
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="50"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/.loyal/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/.loyal/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/.loyal/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/.loyal/config/app.toml

# set minimum gas price and timeout commit
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0.000025ulyl\"/" $HOME/.loyal/config/app.toml

# enable prometheus
sed -i -e "s/prometheus = false/prometheus = true/" $HOME/.loyal/config/config.toml

# reset
loyald tendermint unsafe-reset-all --home $HOME/.loyal

echo -e "\e[1m\e[32m4. Starting service... \e[0m" && sleep 1
# create service
sudo tee /etc/systemd/system/loyald.service > /dev/null <<EOF
[Unit]
Description=loyal
After=network-online.target

[Service]
User=$USER
ExecStart=$(which loyald) start --home $HOME/.loyal
Restart=on-failure
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF

# start service
sudo systemctl daemon-reload
sudo systemctl enable loyald
sudo systemctl restart loyald

echo '=============== SETUP FINISHED ==================='
echo -e 'To check logs: \e[1m\e[32mjournalctl -u loyald -f -o cat\e[0m'
echo -e "To check sync status: \e[1m\e[32mcurl -s localhost:${LOYAL_PORT}657/status | jq .result.sync_info\e[0m"
