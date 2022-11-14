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
SEEDS=""
PEERS="7490c272d1c9db40b7b9b61b0df3bb4365cb63a6@54.80.32.192:26656,b66ecdf36bb19a9af0460b3ae0901aece93ae006@44.211.18.98:26656,a19b19f09084e9f1579243a5613efde8ae5aa946@65.21.199.148:26624,607dbee191f06d9479d7ae8f9fc5de75ca840d6f@185.215.167.227:31656,7617462cde13616cfc2d4c590ef099818e5f46ca@135.181.20.44:2566,0f47d3c784ab55288a780201a3f38066f702fe3a@135.181.176.109:48656,b3a25bb1cc653dfb37205b9b6e590afd66e390ad@209.18.90.20:26656,4dee73af0dfcf44523e82b7b20fcb48ffea5138c@162.19.93.127:26656,f15a7901ea4a3b318ebc196915b72c3cf54dc6d6@18.236.110.150:26656,d5f8d8b15a062817aa8ac1d4de905e1e852a81f2@194.163.148.193:2566,0b0a94003813f2bf8d891f40661ba53a6546a8c6@149.28.200.189:2566,57fc833bf73d3cac97dcf91a8e101c35e1bbb4ab@139.180.141.77:2566,d0e0ca1af09674f71101658f646175b4e17bc5ca@65.20.66.44:2566,dbb485929f41f6cd96dc7abccb65f0f9d73180a1@185.250.36.53:2566,056011f128eb099993db18c4fcdf66d19007a1e8@20.255.163.130:2566,911b315ca74c1f295d1805cf713c433c6decedfd@38.242.153.15:2566,3136e8dbb70e15de949e70a4ed343f9a429d8584@167.99.218.248:2566,1cc290ad5c70027acbd534a13809769640fd0f6f@75.119.144.35:2566,17e0f31850ebe5db70d0bc4f153eb3378920b3b8@216.250.122.218:2566,4976b12c010b22df6bb243be4d2bac49505b6802@185.192.97.126:2566,d6f8ddbff223c5c8ef5f51ebe2490a8f0f17e25f@194.233.77.238:2566,f6153ac4a479a5ef661439ac01017a5c1f109c5e@165.232.163.114:2566,90f8b6e507488bb32cfb4465b32ea24ce7f0cedf@128.199.238.50:2566,49e67c49521e347de873c459fd0311ee17c63932@62.151.183.227:2566,e397a9fc169e7e6721a94f4fd43e0e036aeca2eb@20.163.88.92:2566,8bc9d0a9fae7047fd10a1f8d59304b0bea8b1ccd@161.97.140.6:2566,9d3e2a92c38d499ae0b891563728460d87495feb@198.71.61.63:2566,9771ae4427617b12a49680419a4cb0e15e03a4b4@185.188.249.173:2566,2b9f555e4e0fe197664ed11cd7e1a05c020e5583@178.18.247.240:2566,c9b5c9ac6758bcf5dcddd108d3fc5f7805a70f71@217.160.64.238:2566,4d0927d1f3bd853666afd6399fddee686a70bd95@128.199.176.142:2566,112b8bf9f2672233f2377caf76a437af0cb0ffe3@20.166.24.21:2566,15070caeafb62d2c0f27363890669cd702946d9f@161.35.60.67:2566,14f43f2c814ac0a6546956e53a08325fca5780b0@108.175.1.50:2566,fd23f238dc33ce68313cd44ccb24f0ed39b339c4@185.208.207.37:2566,6da737d895eae548dd128a32369d8fed6085c94e@104.254.247.189:2566,7237e0b01016512c4b26f11d2b73eb4e458f6292@185.215.166.204:2566,cbb624e948a4d878d9152974dbe7cb9366514efc@194.163.162.155:2566,7ec8edefd8d3ea7c0eaf5db84fa4b4f60dbb5140@128.199.218.60:2566,d18aab1807b54c7b8e586e166dd6aac2d44d61e8@159.223.39.86:2566,b8b6f17a6fd4b69d198fa248e3105b93ea48d973@38.242.217.226:2566,14e53c7eae475b8fde1d7e024e9d88efe2b04616@188.166.247.136:2566,f630eb3d031148f656e8b56e60be95f09a0a2105@20.15.224.74:2566,c549997c59be890f12a9d86f89b3ccb9a858ee64@193.203.15.48:2566,89344bd087489f84873b5d245d26c5956febf4fa@103.150.196.211:2566,0f6ae49a796c21de773864b0b227f5ca6f6a60c9@38.242.138.108:2566,4969ffc184b3a22c233c480f585b0eb3ebe0575f@157.245.56.250:2566,5c332ecd0bffe5a6f5142a783489a1ef3f052886@142.93.205.59:2566,0b2113702b974e608a85ee73e1f94cbc5921fe85@149.102.129.254:2566,e6c30c9952302a257f0cbc47159a979cef477511@157.230.63.159:2566,9fa6c4f5e0f3a73a668befcde07b7dfb3119b1c4@161.35.215.48:2566,6de4b209afffb810700ac5407656ac8d0acb5d33@149.102.155.26:2566,e53e92aa6b56122517168f7a4850a14c9c7936ae@198.199.122.214:2566,bc09e5bc8a7f5a49a9c50fee927e3227e5645dcc@108.175.1.164:2566,6aae36d693c9421a88402359d27756a6f8618774@165.232.163.39:2566,e03f974a4d59067e445d9b66aac47f07bd5cc8a2@185.250.36.169:2566,7d65add543debfe636907e31dd464db05f8b01a8@185.135.137.136:2566,af75c1cebd4e67e3e0062b4906679307bdc7c74c@178.128.159.18:2566,8292a767d30eded0feac55b51159becd72b72ccd@174.138.22.89:2566,0810318e9b7b3cf3794d24715cc80355b397abc3@20.102.82.175:2566,57d32a4400be9145892f1b5ea08412d58a2d0960@161.97.133.62:2566,4f80657f51ccc47037694af3f5cae04ffb2b95d7@149.102.159.26:2566,57bd21f1ef48d1e44d6c1ded0d83695cb3cc76da@157.230.36.242:2566,2e3768f50014361c43e7e02a738cace6bb7ced5d@149.102.159.250:2566,3b3da838f9caa8b0babdb13a170a17592a3ba98d@157.245.52.183:2566,1aada59e8e6867d241c3a276dd96d3fd99c2a985@185.202.239.46:2566,8c408810c753909e1135afd4293ac60eff479b5e@165.22.18.152:2566,d69dbd23d7e0ed93eeb9f98c221e17e1c1ce6033@212.227.118.231:13656,a2eed485759d63147204e9e63e05836e5a4ea6ee@159.223.89.66:2566,844996d23989daa50bbabe4b84bc14ec98aa889e@128.199.170.238:2566,b00a09236eec12427ad91e4c505f69a301ad9f06@185.197.250.215:2566,e0ba7dce4cb8b77fc2dc429459b437b92a4fcd02@20.255.233.110:2566,175402fc5e6b12abb7a82600138ee3a23affbf27@159.223.86.212:2566,c1746ba47139141709629423c9d3edc1fb7659fc@165.232.145.9:2566,8e9db92c14f591a5b2fabee987259d94f7ee3293@139.59.236.118:2566,1cfa5ece97cc3d7301a9464999d7b44f74db6759@157.230.250.103:2566,ce7c47621a76c35cb65f88bf677f674ccc1dd4b8@188.166.59.252:2566,4500267f22c9208ab80c0c33b6e756112b0c5a4e@159.65.13.181:2566,1b14a7c71114cad3d8885b97a89f1667c7e75192@139.59.96.62:2566,16b680ac5b3063eb6aaf34d8244ebefb4f853c8f@185.250.36.181:2566,b3f8c5d78d61fc9ac367b0b725047f36d55aeebe@157.245.50.239:2566,2432ce2d74fb45c2b52bb89ee36da726d0111b04@209.145.57.213:2566,aaea8484c0f2596dd289ac80a6eebf5b42851599@157.230.250.84:2566,81172e99ee1056ebeb3df8227142c68d9f8c2332@185.208.207.77:2566,83e5912a538e314ca251858259b3363e41581154@185.208.207.36:2566,45b081644640aced493058a125331493ceaf60dd@95.217.109.218:26656"
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
