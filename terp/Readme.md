<p align="center">
  <img width="300" height="auto" src="https://user-images.githubusercontent.com/108969749/201539131-2a8481bc-7d50-47fe-8db8-96c7372d5a84.png">
</p>

### Spesifikasi Hardware :
NODE  | CPU     | RAM      | SSD     |
| ------------- | ------------- | ------------- | -------- |
| Testnet | 4          | 8         | 200  |

### Install otomatis
```
wget -O terp.sh https://raw.githubusercontent.com/Whalealert/nodetutorial-testnet/main/terp/terp.sh && chmod +x terp.sh && ./terp.sh
```
### Load variable ke system
```
source $HOME/.bash_profile
```
### Informasi node

* cek sync node
```
terpd status 2>&1 | jq .SyncInfo
```
* cek log node
```
journalctl -fu terpd -o cat
```
* cek node info
```
terpd status 2>&1 | jq .NodeInfo
```
* cek validator info
```
terpd status 2>&1 | jq .ValidatorInfo
```
* cek node id
```
terpd tendermint show-node-id
```
### Membuat wallet
* wallet baru
```
terpd keys add $WALLET
```
* recover wallet
```
terpd keys add $WALLET --recover
```
* list wallet
```
terpd keys list
```
* hapus wallet
```
terpd keys delete $WALLET
```
### Simpan informasi wallet
```
TERP_WALLET_ADDRESS=$(terpd keys show $WALLET -a)
TERP_VALOPER_ADDRESS=$(terpd keys show $WALLET --bech val -a)
echo 'export TERP_WALLET_ADDRESS='${TERP_WALLET_ADDRESS} >> $HOME/.bash_profile
echo 'export TERP_VALOPER_ADDRESS='${TERP_VALOPER_ADDRESS} >> $HOME/.bash_profile
source $HOME/.bash_profile
```
### Statesync by #NodeJumper
```
sudo systemctl stop terpd
cp $HOME/.terp/data/priv_validator_state.json $HOME/.terp/priv_validator_state.json.backup
terpd tendermint unsafe-reset-all --home $HOME/.terp --keep-addr-book
rm -rf $HOME/.terp/data 
rm -rf $HOME/.terp/wasm
SNAP_NAME=$(curl -s https://snapshots2-testnet.nodejumper.io/terpnetwork-testnet/ | egrep -o ">athena-2.*\.tar.lz4" | tr -d ">")
curl https://snapshots2-testnet.nodejumper.io/terpnetwork-testnet/${SNAP_NAME} | lz4 -dc - | tar -xf - -C $HOME/.terp
mv $HOME/.terp/priv_validator_state.json.backup $HOME/.terp/data/priv_validator_state.json
sudo systemctl restart terpd
sudo journalctl -u terpd -f --no-hostname -o cat
```
### Membuat validator
* cek balance
```
terpd query bank balances $TERP_WALLET_ADDRESS
```
* membuat validator
```
terpd tx staking create-validator \
  --amount 100000000uterpx \
  --from $WALLET \
  --commission-max-change-rate "0.01" \
  --commission-max-rate "0.2" \
  --commission-rate "0.07" \
  --min-self-delegation "1" \
  --pubkey  $(terpd tendermint show-validator) \
  --moniker $NODENAME \
  --chain-id $TERP_CHAIN_ID
```
* edit validator
```
terd tx staking edit-validator \
  --moniker=$NODENAME \
  --identity=<your_keybase_id> \
  --website="<your_website>" \
  --details="<your_validator_description>" \
  --chain-id=$TERP_CHAIN_ID \
  --from=$WALLET
```
* unjail validator
```
terpd tx slashing unjail \
  --broadcast-mode=block \
  --from=$WALLET \
  --chain-id=$TERP_CHAIN_ID \
  --gas=auto
```
### Voting
```
terpd tx gov vote 1 yes --from $WALLET --chain-id=$TERP_CHAIN_ID
```
### Delegasi dan Rewards
* delegasi
```
terpd tx staking delegate $TERP_VALOPER_ADDRESS 1000000uterpx --from=$WALLET --chain-id=TERP_CHAIN_ID --gas=auto
```
* withdraw reward
```
terpd tx distribution withdraw-all-rewards --from=$WALLET --chain-id=$TERP_CHAIN_ID --gas=auto
```
* withdraw reward beserta komisi
```
terpd tx distribution withdraw-rewards $TERP_VALOPER_ADDRESS --from=$WALLET --commission --chain-id=$TERP_CHAIN_ID
```

### Hapus node
```
sudo systemctl stop terpd
sudo systemctl disable terpd
sudo rm /etc/systemd/system/terp* -rf
sudo rm $(which terpd) -rf
sudo rm $HOME/.terp* -rf
sudo rm -rf terp.sh
sudo rm $HOME/terp -rf
sed -i '/TERP_/d' ~/.bash_profile
```
