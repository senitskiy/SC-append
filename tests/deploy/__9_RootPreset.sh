#!/bin/sh

NETWORK=$(./configes/get_network.sh)
CONTRACTS=$(./configes/get_contracts.sh)
TVM_LINKER=$(./configes/get_tvm_linker.sh)
TONOS_CLI=$(./configes/get_tonos_cli.sh)
CURRENT_DIR=$(./configes/get_current_dir.sh)

# AMOUNT_TONS=6000000000
# GIVER=
# CODE=$($TVM_LINKER decode --tvc ../$CONTRACTS/RootTokenContract.tvc  | grep code: | cut -c 8-)
# CODE=$($TVM_LINKER decode --tvc ../$CONTRACTS/RootTokenContract.tvc | grep code: | cut -c 8-)
CODE=$(cat ./code.txt) #export TVM_WALLET_CODE=`cat code.txt`
# KEYS_FILE="./RootA/deploy.keys.json"
# PUBKEY=$(cat $KEYS_FILE | grep public | cut -c 14-77)


# CODE=$(./tvm_linker decode --tvc ../contracts/TTW_FT.tvc  | grep code: | cut -c 8-)

echo ========================================================================
echo Deploy Root


ROOT_WTON_ADDR_FILE="$CURRENT_DIR/RootWTON/address.json"
ROOT_WTON_ADDR=$(cat $ROOT_WTON_ADDR_FILE | grep address | cut -c 15-80)

WTON_ADDR_FILE="$CURRENT_DIR/WTON/address.json"
WTON_ADDR=$(cat $WTON_ADDR_FILE | grep address | cut -c 15-80)

# mkdir $CURRENT_DIR/Root

ROOT_ADDR=$($TONOS_CLI -u $NETWORK genaddr ../$CONTRACTS/DEXroot.tvc ../$CONTRACTS/DEXroot.abi.json --genkey $CURRENT_DIR/Root/deploy.keys.json --wc 0 | grep "Raw address:" | cut -c 14-)

echo { \"address\": \"$ROOT_ADDR\"} > $CURRENT_DIR/Root/address.json

KEYS_FILE="$CURRENT_DIR/Root/deploy.keys.json"
PUBKEY=$(cat $KEYS_FILE | grep public | cut -c 14-77)
ROOT_OWNER_PK=$PUBKEY

echo Public key: $ROOT_OWNER_PK

echo Waiting. Transaction from Giver...

if [ $NETWORK = "http://127.0.0.1" ]
then
    GIVER_RESULT=$($TONOS_CLI -u $NETWORK call 0:841288ed3b55d9cdafa806807f02a0ae0c169aa5edfe88a789a6482429756a94 sendGrams "{\"dest\":\"$ROOT_ADDR\",\"amount\":\"10000000000\"}" --abi ./local_giver.abi.json | grep "Succeeded" | cut -c 1-)
elif [ $NETWORK = "https://net.ton.dev" ]
then
    GIVER_RESULT=$($TONOS_CLI -u $NETWORK call 0:2225d70ebde618b9c1e3650e603d6748ee6495854e7512dfc9c287349b4dc988 pay '{"addr":"'$ROOT_ADDR'"}' --abi ./giver.abi.json  | grep "Succeeded" | cut -c 1-)
fi

echo Result transaction from Giver: $GIVER_RESULT

echo RootA: $ROOT_ADDR

ROOT_DATA='{"wTONroot":"'$ROOT_WTON_ADDR'","wTONwrapper":"'$WTON_ADDR'"}'

echo Waiting. Deploy Root from Blockchain...
RESULT_DEPLOY=$($TONOS_CLI -u $NETWORK deploy ../$CONTRACTS/DEXroot.tvc $ROOT_DATA --abi ../$CONTRACTS/DEXroot.abi.json --sign $CURRENT_DIR/Root/deploy.keys.json --wc 0 | grep "Transaction" | cut -c 12-) #| awk '/Transaction /')

echo Status Deploy: $RESULT_DEPLOY
# ./tonos-cli -u "http://127.0.0.1" call "0:841288ed3b55d9cdafa806807f02a0ae0c169aa5edfe88a789a6482429756a94" sendGrams "{\"dest\":\"0:b91e58c842b3fa41b644b96af57f83b458e4a02242aa0ec47b1f90776559b21b\",\"amount\":\"10000000000\"}" --abi ./local_giver.abi.json

# export TVM_WALLET_CODE=`cat code.txt`

# ./tonos-cli -u "http://127.0.0.1" deploy ../DEX-core-smart-contracts/RootTokenContract.tvc '{"name":"526f6f7441","symbol":"525441", "decimals":"9","root_public_key":"0x6f890c589d1501024e09a905c87f4787174854d793b6d2233a70fbebedf861d3", "root_owner":"0", "wallet_code":"'$TVM_WALLET_CODE'","total_supply":"1000000"}' --abi ../DEX-core-smart-contracts/RootTokenContract.abi --sign ./RootA/deploy.keys.json --wc 0

# ./tonos-cli -u "http://127.0.0.1" genaddr ../DEX-core-smart-contracts/RootTokenContract.tvc ../DEX-core-smart-contracts/RootTokenContract.abi --setkey ./RootA/deploy.keys.json --wc 0


ACCOUNT_STATUS=$($TONOS_CLI -u $NETWORK account $ROOT_ADDR | grep "acc_type:" | cut -c 10-)
echo Status account: $ACCOUNT_STATUS

GETWRAPPEDTONROOT=$($TONOS_CLI -u $NETWORK run $ROOT_ADDR wrappedTONroot {} --abi ../$CONTRACTS/DEXroot.abi.json | grep "value0" | cut -c 13-)
echo Wrapped TON root: $(echo -n $GETWRAPPEDTONROOT | xxd -r -p)

GETTONWRAPPER=$($TONOS_CLI -u $NETWORK run $ROOT_ADDR TONwrapper {} --abi ../$CONTRACTS/DEXroot.abi.json | grep "value0" | cut -c 13-)
echo TON wrapper: $(echo -n $GETTONWRAPPER | xxd -r -p)

GETTEST1=$($TONOS_CLI -u $NETWORK run $ROOT_ADDR test1 {} --abi ../$CONTRACTS/DEXroot.abi.json | grep "value0" | cut -c 13-)
echo test1: $GETTEST1

GETTEST2=$($TONOS_CLI -u $NETWORK run $ROOT_ADDR test2 {} --abi ../$CONTRACTS/DEXroot.abi.json | grep "value0" | cut -c 13-)
echo test2: $GETTEST2

GETTEST3=$($TONOS_CLI -u $NETWORK run $ROOT_ADDR test3 {} --abi ../$CONTRACTS/DEXroot.abi.json | grep "value0" | cut -c 13-)
echo test3: $GETTEST3

GETTEST4=$($TONOS_CLI -u $NETWORK run $ROOT_ADDR test4 {} --abi ../$CONTRACTS/DEXroot.abi.json | grep "value0" | cut -c 13-)
echo test4: $GETTEST4

GETTEST5=$($TONOS_CLI -u $NETWORK run $ROOT_ADDR test5 {} --abi ../$CONTRACTS/DEXroot.abi.json | grep "value0" | cut -c 13-)
echo test5: $GETTEST5

GETPAIRS=$($TONOS_CLI -u $NETWORK run $ROOT_ADDR pairs {} --abi ../$CONTRACTS/DEXroot.abi.json | grep "value0" | cut -c 13-)
echo pairs: $GETPAIRS

GETPAIRKEYS=$($TONOS_CLI -u $NETWORK run $ROOT_ADDR pairKeys {} --abi ../$CONTRACTS/DEXroot.abi.json | grep "value0" | cut -c 13-)
echo pairKeys: $GETPAIRKEYS

GETCLIENTS=$($TONOS_CLI -u $NETWORK run $ROOT_ADDR clients {} --abi ../$CONTRACTS/DEXroot.abi.json | grep "value0" | cut -c 13-)
echo clients: $GETCLIENTS

GETCLIENTKEYS=$($TONOS_CLI -u $NETWORK run $ROOT_ADDR clientKeys {} --abi ../$CONTRACTS/DEXroot.abi.json | grep "value0" | cut -c 13-)
echo clientKeys: $GETCLIENTKEYS

GETCLIENTKEYS=$($TONOS_CLI -u $NETWORK run $ROOT_ADDR clientKeys {} --abi ../$CONTRACTS/DEXroot.abi.json | grep "value0" | cut -c 13-)
echo clientKeys: $GETCLIENTKEYS

GETBALANCETONGRAMS=$($TONOS_CLI -u $NETWORK run $ROOT_ADDR getBalanceTONgrams {} --abi ../$CONTRACTS/DEXroot.abi.json | grep "value0" | cut -c 13-)
echo get Balance TON grams: $GETBALANCETONGRAMS


# GETWALLETADDRESS=$($TONOS_CLI -u $NETWORK run $ROOT_ADDR getWalletAddress {} --abi ../$CONTRACTS/RootTokenContract.abi | grep "value0" | cut -c 13-)
# echo Total granted: $GETWALLETADDRESS