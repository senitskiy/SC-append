#!/bin/sh

NETWORK=$(./configes/get_network.sh)
CONTRACTS=$(./configes/get_contracts.sh)
TVM_LINKER=$(./configes/get_tvm_linker.sh)
TONOS_CLI=$(./configes/get_tonos_cli.sh)
CURRENT_DIR=$(./configes/get_current_dir.sh)

# AMOUNT_TONS=6000000000
# GIVER="0:841288ed3b55d9cdafa806807f02a0ae0c169aa5edfe88a789a6482429756a94"
# CODE=$($TVM_LINKER decode --tvc ../$CONTRACTS/RootTokenContract.tvc  | grep code: | cut -c 8-)
# CODE=$($TVM_LINKER decode --tvc ../$CONTRACTS/RootTokenContract.tvc | grep code: | cut -c 8-)
CODE=$(cat ./code.txt) #export TVM_WALLET_CODE=`cat code.txt`
# KEYS_FILE="./client1/deploy.keys.json"
# PUBKEY=$(cat $KEYS_FILE | grep public | cut -c 14-77)


# CODE=$(./tvm_linker decode --tvc ../contracts/TTW_FT.tvc  | grep code: | cut -c 8-)

ROOT_NAME=$(echo -n "RootA" | xxd -p )
ROOT_SYMBOL=$(echo -n "RTA" | xxd -p )
ROOT_DECIMALS="9"
# ROOT_OWNER_PK=$PUBKEY
ROOT_OWNER=0
ROOT_OWNER_ADDRESS=$ZERO_ADDRESS
ROOT_CODE=$CODE
TOTAL_SUPPLY="1000000" 

# ROOT_DATA='{"_name":"'$ROOT_NAME'","_symbol":"'$ROOT_SYMBOL'","_decimals":'$ROOT_DECIMALS',"_rootPublicKey":"0x'$ROOT_OWNER_PK'","_rootOwnerAddress":"'$ZERO_ADDRESS'","_code":"'$CODE'"}'
echo ========================================================================
echo Deploy client1

mkdir $CURRENT_DIR/client1

CLIENT_ADDR=$($TONOS_CLI -u $NETWORK genaddr ../$CONTRACTS/DEXclient.tvc ../$CONTRACTS/DEXclient.abi.json --genkey $CURRENT_DIR/client1/deploy.keys.json --wc 0 | grep "Raw address:" | cut -c 14-)
# # tonos-cli genaddr ../DEXrootAndWalletcompile/RootTokenContract.tvc ../DEXrootAndWalletcompile/RootTokenContract.abi.json --genkey ./addrsAndKeys/2021-04-12-150601/RootA/deploy.keys.json --wc 0
echo { \"address\": \"$CLIENT_ADDR\"} > $CURRENT_DIR/client1/address.json

KEYS_FILE="$CURRENT_DIR/client1/deploy.keys.json"
PUBKEY=$(cat $KEYS_FILE | grep public | cut -c 14-77)

ROOT_DATA='{"pubkey":"'0x$PUBKEY'"}'


echo 0x$PUBKEY

ROOT_ADDR_FILE="$CURRENT_DIR/DEXroot/address.json"
DEX_ROOT_ADDR=$(cat $ROOT_ADDR_FILE | grep address | cut -c 15-80)
echo Root: $DEX_ROOT_ADDR

# echo $CLIENT_ADDR

DEPLOYDEADDRESS=$($TONOS_CLI -u $NETWORK run $DEX_ROOT_ADDR computeDEXclientAddr $ROOT_DATA --abi ../$CONTRACTS/DEXroot.abi.json | grep "value0" | cut -c 14-79)

echo deployedAddress: $DEPLOYDEADDRESS



echo Waiting. Transaction from Giver...

if [ $NETWORK = "http://127.0.0.1" ]
then
    $TONOS_CLI -u $NETWORK call 0:841288ed3b55d9cdafa806807f02a0ae0c169aa5edfe88a789a6482429756a94 sendGrams "{\"dest\":\"$DEPLOYDEADDRESS\",\"amount\":\"100000000000\"}" --abi ./local_giver.abi.json
elif [ $NETWORK = "https://net.ton.dev" ] 
then
    GIVER_RESULT=$($TONOS_CLI -u $NETWORK call 0:2225d70ebde618b9c1e3650e603d6748ee6495854e7512dfc9c287349b4dc988 pay '{"addr":"'$DEPLOYDEADDRESS'"}' --abi ./giver.abi.json | grep "Succeeded" | cut -c 1-)
fi

echo $GIVER_RESULT

# ROOT_DATA='{"pubkey":"'0x$PUBKEY'"}'

# DEPLOYDEADDRESS=$(
    $TONOS_CLI -u $NETWORK run $DEX_ROOT_ADDR createDEXclient $ROOT_DATA --abi ../$CONTRACTS/DEXroot.abi.json #| grep "deployedAddress" | cut -c 23-88)

# echo deployedAddress: $DEPLOYDEADDRESS







# ACCOUNT_STATUS=$(
    $TONOS_CLI -u $NETWORK account $DEPLOYDEADDRESS #| grep "acc_type:" | cut -c 11-)
# echo Status account: $ACCOUNT_STATUS


