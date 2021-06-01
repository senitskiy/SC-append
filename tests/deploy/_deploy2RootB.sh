#!/bin/sh

NETWORK=$(./configes/get_network.sh)
CONTRACTS=$(./configes/get_contracts.sh)
TVM_LINKER=$(./configes/get_tvm_linker.sh)
TONOS_CLI=$(./configes/get_tonos_cli.sh)
CURRENT_DIR=$(./configes/get_current_dir.sh)

# echo $NETWORK
# echo $CONTRACTS
# echo $TVM_LINKER
# echo $TONOS_CLI

AMOUNT_TONS=6000000000
# GIVER="0:841288ed3b55d9cdafa806807f02a0ae0c169aa5edfe88a789a6482429756a94"
# CODE=$($TVM_LINKER decode --tvc ../$CONTRACTS/RootTokenContract.tvc  | grep code: | cut -c 8-)
# CODE=$($TVM_LINKER decode --tvc ../$CONTRACTS/RootTokenContract.tvc | grep code: | cut -c 8-)
CODE=$(cat ./code.txt) #export TVM_WALLET_CODE=`cat code.txt`
# KEYS_FILE="./RootB/deploy.keys.json"
# PUBKEY=$(cat $KEYS_FILE | grep public | cut -c 14-77)


# CODE=$(./tvm_linker decode --tvc ../contracts/TTW_FT.tvc  | grep code: | cut -c 8-)

ROOT_NAME=$(echo -n "RootB" | xxd -p )
ROOT_SYMBOL=$(echo -n "RTB" | xxd -p )
ROOT_DECIMALS="9"
# ROOT_OWNER_PK=$PUBKEY
ROOT_OWNER=0
ROOT_OWNER_ADDRESS=$ZERO_ADDRESS
ROOT_CODE=$CODE
TOTAL_SUPPLY="1000000" 

# ROOT_DATA='{"_name":"'$ROOT_NAME'","_symbol":"'$ROOT_SYMBOL'","_decimals":'$ROOT_DECIMALS',"_rootPublicKey":"0x'$ROOT_OWNER_PK'","_rootOwnerAddress":"'$ZERO_ADDRESS'","_code":"'$CODE'"}'

# ROOT_ADDR_FILE="./RootB/address.json"
# ROOT_ADDR=$(cat $ROOT_ADDR_FILE | grep address | cut -c 15-80)

echo ========================================================================
echo Deploy Root B
# $TONOS_CLI -u $NETWORK call $GIVER sendGrams "{\"dest\":\"$ROOT_ADDR\",\"amount\":\"$AMOUNT_TONS\"}" --abi ./local_giver.abi.json > /dev/null

# DIR=$(date +"%Y-%m-%d-%k%M%S" | cut -c 1-17)
# CURRENT_DIR="./addrsAndKeys/"${DIR}
# echo Directory Address and keys: $CURRENT_DIR
# mkdir $CURRENT_DIR

SEED_PHRASE=$($TONOS_CLI -u $NETWORK genphrase | grep phrase | cut -c 14-110 ) #| tr -d \")
# SEED_PHRASE=$(tonos-cli genphrase | grep phrase | cut -c 14-110)
# SEED_PHRASE_=${$SEED_PHRASE/"\""/}
# echo $SEED_PHRASE

mkdir $CURRENT_DIR/RootB
# $TONOS_CLI -u $NETWORK getkeypair $CURRENT_DIR/RootA/deploy.keys.json $SEED_PHRASE #"there screen toddler confirm spring future grief loan wait ready accuse card" # $SEED_PHRASE #| grep Succeeded | cut -c 1-15
# tonos-cli getkeypair ./addrsAndKeys/RootA/deploy.keys.json "age rescue knock load gaze erupt zoo elevator romance basic polar august" | grep Succeeded | cut -c 1-15

ROOT_ADDR=$($TONOS_CLI -u $NETWORK genaddr ../$CONTRACTS/RootTokenContract.tvc ../$CONTRACTS/RootTokenContract.abi.json --genkey $CURRENT_DIR/RootB/deploy.keys.json --wc 0 | grep "Raw address:" | cut -c 14-)
# tonos-cli genaddr ../DEXrootAndWalletcompile/RootTokenContract.tvc ../DEXrootAndWalletcompile/RootTokenContract.abi.json --genkey ./addrsAndKeys/2021-04-12-150601/RootA/deploy.keys.json --wc 0

echo { \"address\": \"$ROOT_ADDR\"} > $CURRENT_DIR/RootB/address.json

KEYS_FILE="$CURRENT_DIR/RootB/deploy.keys.json"
PUBKEY=$(cat $KEYS_FILE | grep public | cut -c 14-77)
ROOT_OWNER_PK=$PUBKEY

echo Public key: $ROOT_OWNER_PK

echo Waiting. Transaction from Giver...

if [ $NETWORK = "http://127.0.0.1" ]
then
    $TONOS_CLI -u $NETWORK call 0:841288ed3b55d9cdafa806807f02a0ae0c169aa5edfe88a789a6482429756a94 sendGrams "{\"dest\":\"$ROOT_ADDR\",\"amount\":\"$AMOUNT_TONS\"}" --abi ./local_giver.abi.json > /dev/null
elif [ $NETWORK = "https://net.ton.dev" ]
then
    GIVER_RESULT=$($TONOS_CLI -u $NETWORK call 0:2225d70ebde618b9c1e3650e603d6748ee6495854e7512dfc9c287349b4dc988 pay '{"addr":"'$ROOT_ADDR'"}' --abi ./giver.abi.json | grep "Succeeded" | cut -c 1-)
fi

echo Result transaction from Giver: $GIVER_RESULT
echo RootB: $ROOT_ADDR

ROOT_DATA='{"name":"'$ROOT_NAME'","symbol":"'$ROOT_SYMBOL'","decimals":"'$ROOT_DECIMALS'","root_public_key":"0x'$ROOT_OWNER_PK'","root_owner":"'$ROOT_OWNER'","wallet_code":"'$ROOT_CODE'","total_supply":"'$TOTAL_SUPPLY'"}'
# '{"name":"${nameRootTokenHex}","symbol":"${symbolRootTokenHex}", "decimals":"${decimals}","root_public_key":"0x${contractKeysPublic}", "root_owner":"${root_owner}", "wallet_code":"'${TVM_WALLET_CODE.TVM_WALLET_CODE}'","total_supply":"${total_supply}"}'

echo Waiting. Deploy Root from Blockchain...
RESULT_DEPLOY=$($TONOS_CLI -u $NETWORK deploy ../$CONTRACTS/RootTokenContract.tvc $ROOT_DATA --abi ../$CONTRACTS/RootTokenContract.abi.json --sign $CURRENT_DIR/RootB/deploy.keys.json --wc 0 | grep "Transaction" | cut -c 12-) 
# RESULT_DEPLOY=$($TONOS_CLI -u $NETWORK deploy ../$CONTRACTS/RootTokenContract.tvc $ROOT_DATA --abi ../$CONTRACTS/RootTokenContract.abi --sign ./RootA/deploy.keys.json --wc 0 | grep "Transaction" | cut -c 12-) #| awk '/Transaction /')

echo Status Deploy: $RESULT_DEPLOY

ACCOUNT_STATUS=$($TONOS_CLI -u $NETWORK account $ROOT_ADDR | grep "acc_type:" | cut -c 10-)
echo Status account: $ACCOUNT_STATUS

GETNAME=$($TONOS_CLI -u $NETWORK run $ROOT_ADDR getName {} --abi ../$CONTRACTS/RootTokenContract.abi.json | grep "value0" | cut -c 13-)
echo Name Root: $(echo -n $GETNAME | xxd -r -p)

GETSYMBOL=$($TONOS_CLI -u $NETWORK run $ROOT_ADDR getSymbol {} --abi ../$CONTRACTS/RootTokenContract.abi.json | grep "value0" | cut -c 13-)
echo Symbol Root: $(echo -n $GETSYMBOL | xxd -r -p)

GETDECIMALS=$($TONOS_CLI -u $NETWORK run $ROOT_ADDR getDecimals {} --abi ../$CONTRACTS/RootTokenContract.abi.json | grep "value0" | cut -c 13-)
echo Decimals Root: $GETDECIMALS

GETROOTKEY=$($TONOS_CLI -u $NETWORK run $ROOT_ADDR getRootKey {} --abi ../$CONTRACTS/RootTokenContract.abi.json | grep "value0" | cut -c 13-)
echo Root key: $GETROOTKEY

GETTOTALSUPPLY=$($TONOS_CLI -u $NETWORK run $ROOT_ADDR getTotalSupply {} --abi ../$CONTRACTS/RootTokenContract.abi.json | grep "value0" | cut -c 13-)
echo Total supply: $GETTOTALSUPPLY

GETTOTALGRANTED=$($TONOS_CLI -u $NETWORK run $ROOT_ADDR getTotalGranted {} --abi ../$CONTRACTS/RootTokenContract.abi.json | grep "value0" | cut -c 13-)
echo Total granted: $GETTOTALGRANTED