### Spesifikasi Hardware :
NODE  | CPU     | RAM      | SSD     |
| ------------- | ------------- | ------------- | -------- |
| Testnet | 4          | 8         | 200  |

### Install otomatis
```
wget -O loyal.sh https://raw.githubusercontent.com/Whalealert/nodetutorial-testnet/main/loyal/loyal.sh && chmod +x loyal.sh && ./loyal.sh
```
### Load variable ke system
```
source $HOME/.bash_profile
```
### Informasi node

   * cek sync node
```
loyald status 2>&1 | jq .SyncInfo
```
   * cek log node
```
journalctl -fu loyald -o cat
```
   * cek node info
```
loyald status 2>&1 | jq .NodeInfo
```
   * cek validator info
```
loyald status 2>&1 | jq .ValidatorInfo
```
  * cek node id
```
loyald tendermint show-node-id
```

### Membuat wallet
   * wallet baru
```
loyald keys add $WALLET
```
   * recover wallet
```
loyald keys add $WALLET --recover
```
   * list wallet
```
loyald keys list
```
   * hapus wallet
```
loyald keys delete $WALLET
```
### Simpan informasi wallet
```
LOYAL_WALLET_ADDRESS=$(loyald keys show $WALLET -a)
LOYAL_VALOPER_ADDRESS=$(loyald keys show $WALLET --bech val -a)
echo 'export LOYAL_WALLET_ADDRESS='${LOYAL_WALLET_ADDRESS} >> $HOME/.bash_profile
echo 'export LOYAL_VALOPER_ADDRESS='${LOYAL_VALOPER_ADDRESS} >> $HOME/.bash_profile
source $HOME/.bash_profile
```
### Statesync by #Polkachu
```
SNAP_RPC="https://loyal-testnet-rpc.polkachu.com:443"
LATEST_HEIGHT=$(curl -s $SNAP_RPC/block | jq -r .result.block.header.height); \
BLOCK_HEIGHT=$((LATEST_HEIGHT - 2000)); \
TRUST_HASH=$(curl -s "$SNAP_RPC/block?height=$BLOCK_HEIGHT" | jq -r .result.block_id.hash)
sed -i.bak -E "s|^(enable[[:space:]]+=[[:space:]]+).*$|\1true| ; \
s|^(rpc_servers[[:space:]]+=[[:space:]]+).*$|\1\"$SNAP_RPC,$SNAP_RPC\"| ; \
s|^(trust_height[[:space:]]+=[[:space:]]+).*$|\1$BLOCK_HEIGHT| ; \
s|^(trust_hash[[:space:]]+=[[:space:]]+).*$|\1\"$TRUST_HASH\"|" $HOME/.loyal/config/config.toml
systemctl restart loyald && journalctl -fu loyald -o cat
```
### Membuat validator
 * cek balance
```
loyald query bank balances $LOYAL_WALLET_ADDRESS
```
 * membuat validator
```
loyald tx staking create-validator \
  --amount 8000000ulyl \
  --from $WALLET \
  --commission-max-change-rate "0.01" \
  --commission-max-rate "0.2" \
  --commission-rate "0.07" \
  --min-self-delegation "1" \
  --pubkey  $(loyald tendermint show-validator) \
  --moniker $NODENAME \
  --fees 250ulyl \
  --chain-id $LOYAL_CHAIN_ID
```
 * edit validator
```
loyald tx staking edit-validator \
  --moniker=$NODENAME \
  --identity=<your_keybase_id> \
  --website="<your_website>" \
  --details="<your_validator_description>" \
  --chain-id=$LOYAL_CHAIN_ID \
  --fees 250ulyl \
  --from=$WALLET
```
 ° unjail validator
```
loyald tx slashing unjail \
  --broadcast-mode=block \
  --from=$WALLET \
  --chain-id=$LOYAL_CHAIN_ID \
  --gas=auto \
  --fees=250ulyl
```
### Voting
```
loyald tx gov vote 1 yes --from $WALLET --chain-id=$LOYAL_CHAIN_ID
```
### Delegasi dan Rewards
  * delegasi
```
loyald tx staking delegate $LOYAL_VALOPER_ADDRESS 1000000ulyl --from=$WALLET --chain-id=LOYAL_CHAIN_ID --fees=250ulyl
```
  * withdraw reward
```
loyald tx distribution withdraw-all-rewards --from=$WALLET --chain-id=$LOYAL_CHAIN_ID --fees=250ulyl
```
  * withdraw reward beserta komisi
```
loyald tx distribution withdraw-rewards $LOYAL_VALOPER_ADDRESS --from=$WALLET --commission --chain-id=$LOYAL_CHAIN_ID
```

### Hapus node
```
sudo systemctl stop loyald
sudo systemctl disable loyald
sudo rm /etc/systemd/system/loyal* -rf
sudo rm $(which loyald) -rf
sudo rm $HOME/.loyal* -rf
sudo rm -rf loyal.sh
sudo rm $HOME/loyal -rf
sed -i '/LOYAL_/d' ~/.bash_profile
```
