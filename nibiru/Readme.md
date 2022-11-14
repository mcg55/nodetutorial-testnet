<p align="center">
  <img width="300" height="auto" src="https://user-images.githubusercontent.com/108969749/201539536-bec9123c-66f5-4048-874b-d851b533e165.jpeg">
</p>

### Spesifikasi Hardware :
NODE  | CPU     | RAM      | SSD     |
| ------------- | ------------- | ------------- | -------- |
| Testnet | 4          | 8         | 200  |

### Install otomatis
```
wget -O nibiru.sh https://raw.githubusercontent.com/Whalealert/nodetutorial-testnet/main/nibiru/nibiru.sh && chmod +x nibiru.sh && ./nibiru.sh
```
### Load variable ke system
```
source $HOME/.bash_profile
```
### Informasi node

* cek sync node
```
nibid status 2>&1 | jq .SyncInfo
```
* cek log node
```
journalctl -fu nibid -o cat
```
* cek node info
```
nibid status 2>&1 | jq .NodeInfo
```
* cek validator info
```
nibid status 2>&1 | jq .ValidatorInfo
```
* cek node id
```
nibid tendermint show-node-id
```
### Membuat wallet
* wallet baru
```
nibid keys add $WALLET
```
* recover wallet
```
nibid keys add $WALLET --recover
```
* list wallet
```
nibid keys list
```
* hapus wallet
```
nibid keys delete $WALLET
```
### Simpan informasi wallet
```
NIBI_WALLET_ADDRESS=$(nibid keys show $WALLET -a)
NIBI_VALOPER_ADDRESS=$(nibid keys show $WALLET --bech val -a)
echo 'export NIBI_WALLET_ADDRESS='${NIBI_WALLET_ADDRESS} >> $HOME/.bash_profile
echo 'export NIBI_VALOPER_ADDRESS='${NIBI_VALOPER_ADDRESS} >> $HOME/.bash_profile
source $HOME/.bash_profile
```
### Snapshot by #NodeJumper
```
sudo systemctl stop nibid
cp $HOME/.nibid/data/priv_validator_state.json $HOME/.nibid/priv_validator_state.json.backup
nibid tendermint unsafe-reset-all --home $HOME/.nibid --keep-addr-book
rm -rf $HOME/.nibid/data 
SNAP_NAME=$(curl -s https://snapshots3-testnet.nodejumper.io/nibiru-testnet/ | egrep -o ">nibiru-testnet-1.*\.tar.lz4" | tr -d ">")
curl https://snapshots3-testnet.nodejumper.io/nibiru-testnet/${SNAP_NAME} | lz4 -dc - | tar -xf - -C $HOME/.nibid
mv $HOME/.nibid/priv_validator_state.json.backup $HOME/.nibid/data/priv_validator_state.json
sudo systemctl restart nibid
sudo journalctl -u nibid -f --no-hostname -o cat
```
### Membuat validator
* cek balance
```
nibid query bank balances $NIBI_WALLET_ADDRESS
```
* membuat validator
```
nibid tx staking create-validator \
  --amount 8000000unibi \
  --from $WALLET \
  --commission-max-change-rate "0.01" \
  --commission-max-rate "0.2" \
  --commission-rate "0.07" \
  --min-self-delegation "1" \
  --pubkey  $(nibid tendermint show-validator) \
  --moniker $NODENAME \
  --fees 250unibi \
  --chain-id $NIBI_CHAIN_ID
```
* edit validator
```
nibid tx staking edit-validator \
  --moniker=$NODENAME \
  --identity=<your_keybase_id> \
  --website="<your_website>" \
  --details="<your_validator_description>" \
  --chain-id=$NIBI_CHAIN_ID \
  --fees 250unibi \
  --from=$WALLET
```
* unjail validator
```
nibid tx slashing unjail \
  --broadcast-mode=block \
  --from=$WALLET \
  --chain-id=$NIBI_CHAIN_ID \
  --gas=auto \
  --fees=250unibi
```
### Voting
```
nibid tx gov vote 1 yes --from $WALLET --chain-id=$NIBI_CHAIN_ID
```
### Delegasi dan Rewards
* delegasi
```
nibid tx staking delegate $NIBI_VALOPER_ADDRESS 1000000unibi --from=$WALLET --chain-id=NIBI_CHAIN_ID --fees=250unibi
```
* withdraw reward
```
nibid tx distribution withdraw-all-rewards --from=$WALLET --chain-id=$NIBI_CHAIN_ID --fees=250unibi
```
* withdraw reward beserta komisi
```
nibid tx distribution withdraw-rewards $NIBI_VALOPER_ADDRESS --from=$WALLET --commission --chain-id=$NIBI_CHAIN_ID
```

### Hapus node
```
sudo systemctl stop nibid && \
sudo systemctl disable nibid && \
rm /etc/systemd/system/nibid.service && \
sudo systemctl daemon-reload && \
cd $HOME && \
rm -rf nibiru.sh && \
rm -rf .nibid && \
rm -rf $(which nibid)
```
