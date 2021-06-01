#!/bin/sh

NETWORK=$(./configes/get_network.sh)
CONTRACTS=$(./configes/get_contracts.sh)
TVM_LINKER=$(./configes/get_tvm_linker.sh)
TONOS_CLI=$(./configes/get_tonos_cli.sh)
CURRENT_DIR=$(./configes/get_current_dir.sh)

echo ========================================================================
echo Deploy Pairs BTC-wUSDT

mkdir $CURRENT_DIR/pairBTC-wUSDT
mkdir $CURRENT_DIR/pairETH-wUSDT
mkdir $CURRENT_DIR/pairTON-BTC
mkdir $CURRENT_DIR/pairTON-ETH
mkdir $CURRENT_DIR/pairTON-wUSDT

PAIR_ADDR=$($TONOS_CLI -u $NETWORK genaddr ../$CONTRACTS/DEXpair.tvc ../$CONTRACTS/DEXpair.abi.json --genkey $CURRENT_DIR/pairBTC-wUSDT/deploy.keys.json --wc 0 | grep "Raw address:" | cut -c 14-)
echo { \"address\": \"$PAIR_ADDR\"} > $CURRENT_DIR/pairBTC-wUSDT/address.json

KEYS_FILE="$CURRENT_DIR/pairBTC-wUSDT/deploy.keys.json"
PUBKEY=$(cat $KEYS_FILE | grep public | cut -c 14-77)

ROOT_DATA='{"pubkey":"'0x$PUBKEY'"}'

echo 0x$PUBKEY

ROOT_ADDR_FILE="$CURRENT_DIR/DEXroot/address.json"
DEX_ROOT_ADDR=$(cat $ROOT_ADDR_FILE | grep address | cut -c 15-80)
echo Root: $DEX_ROOT_ADDR

# echo $CLIENT_ADDR

DEPLOYDEADDRESS=$($TONOS_CLI -u $NETWORK call $DEX_ROOT_ADDR computeDEXpairAddr $ROOT_DATA --abi ../$CONTRACTS/DEXroot.abi.json --sign $CURRENT_DIR/DEXroot/deploy.keys.json | grep "value0" | cut -c 14-79)

echo deployedAddress: $DEPLOYDEADDRESS



echo Waiting. Transaction from Giver...

if [ $NETWORK = "http://127.0.0.1" ]
then
    GIVER_RESULT=$($TONOS_CLI -u $NETWORK call 0:841288ed3b55d9cdafa806807f02a0ae0c169aa5edfe88a789a6482429756a94 sendGrams "{\"dest\":\"$DEPLOYDEADDRESS\",\"amount\":\"100000000000\"}" --abi ./local_giver.abi.json | grep "Succeeded" | cut -c 1-)
elif [ $NETWORK = "https://net.ton.dev" ] 
then
    GIVER_RESULT=$($TONOS_CLI -u $NETWORK call 0:2225d70ebde618b9c1e3650e603d6748ee6495854e7512dfc9c287349b4dc988 pay '{"addr":"'$DEPLOYDEADDRESS'"}' --abi ./giver.abi.json | grep "Succeeded" | cut -c 1-)
fi

echo $GIVER_RESULT


# BTC-wUSDT
ROOT_ADDR_FILE_BTC="$CURRENT_DIR/RootBTC/address.json"
ROOT_ADDR_BTC=$(cat $ROOT_ADDR_FILE_BTC | grep address | cut -c 17-80)
echo Root BTC: $ROOT_ADDR_BTC

ROOT_ADDR_FILE_wUSDT="$CURRENT_DIR/RootwUSDT/address.json"
ROOT_ADDR_USDT=$(cat $ROOT_ADDR_FILE_wUSDT | grep address | cut -c 17-80)
echo Root USDT: $ROOT_ADDR_USDT


ROOT_DATA='{"root0":"'$ROOT_ADDR_BTC'","root1":"'$ROOT_ADDR_USDT'","createId":"'1'"}'


# DEPLOYDEADDRESS=$(
    $TONOS_CLI -u $NETWORK call $DEX_ROOT_ADDR createDEXpair $ROOT_DATA --sign $CURRENT_DIR/DEXroot/deploy.keys.json --abi ../$CONTRACTS/DEXroot.abi.json #| grep "deployedAddress" | cut -c 23-88)
# echo deployedAddress: $DEPLOYDEADDRESS


# ACCOUNT_STATUS=$(
    $TONOS_CLI -u $NETWORK account $DEPLOYDEADDRESS #| grep "acc_type:" | cut -c 11-)
# echo Status account: $ACCOUNT_STATUS


