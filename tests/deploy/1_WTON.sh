#!/bin/sh

NETWORK=$(./configes/get_network.sh)
CONTRACTS=$(./configes/get_contracts.sh)
TVM_LINKER=$(./configes/get_tvm_linker.sh)
TONOS_CLI=$(./configes/get_tonos_cli.sh)
CURRENT_DIR=$(./configes/get_current_dir.sh)


# AMOUNT_TONS=100000000000
# GIVER="0:841288ed3b55d9cdafa806807f02a0ae0c169aa5edfe88a789a6482429756a94"
# CODE=$($TVM_LINKER decode --tvc ../$CONTRACTS/RootTokenContract.tvc  | grep code: | cut -c 8-)
# CODE=$($TVM_LINKER decode --tvc ../$CONTRACTS/RootTokenContract.tvc | grep code: | cut -c 8-)
CODE=$(cat ./code.txt) #export TVM_WALLET_CODE=`cat code.txt`
# KEYS_FILE="./WTON/deploy.keys.json"
# PUBKEY=$(cat $KEYS_FILE | grep public | cut -c 14-77)


# cp TONwrapper.sol TONwrapperDone.sol

echo ========================================================================
echo Deploy WTON

mkdir $CURRENT_DIR/WTON
mkdir $CURRENT_DIR/RootWTON



# ROOT_ADDR_FILE="./WTON/address.json"
# ROOT_ADDR=$(cat $ROOT_ADDR_FILE | grep address | cut -c 15-80)









# ROOT_WTON_ADDR_FILE="./RootWTON/address.json"
# ROOT_WTON_ADDR=$(cat $ROOT_WTON_ADDR_FILE | grep address | cut -c 15-80)
# echo $ROOT_WTON_ADDR


# cp TONwrapper.sol TONwrapperDone.sol

# search="ROOT_WRAPPED_TON = address();"
# replace="ROOT_WRAPPED_TON = address("$addressWTON");"
# sed -i "s/$search/$replace/" TONwrapperDone.sol

# sudo tondev sol compile TONwrapper.sol | awk '/Saved contract /'

# CODE=$(./tvm_linker decode --tvc ../contracts/TTW_FT.tvc  | grep code: | cut -c 8-)

ROOT_NAME=$(echo -n "RootWTON" | xxd -p )
ROOT_SYMBOL=$(echo -n "RWTN" | xxd -p )
ROOT_DECIMALS="9"
ROOT_OWNER_PK=$PUBKEY
ROOT_OWNER=0
ROOT_OWNER_ADDRESS=$ZERO_ADDRESS
ROOT_CODE=$CODE
TOTAL_SUPPLY="1000000" 

# $TONOS_CLI -u $NETWORK call $GIVER sendGrams "{\"dest\":\"$ROOT_ADDR\",\"amount\":\"$AMOUNT_TONS\"}" --abi ./local_giver.abi.json > /dev/null




# DIR=$(date +"%Y-%m-%d-%k%M%S" | cut -c 1-17)
# CURRENT_DIR="./addrsAndKeys/"${DIR}
# # echo Directory Address and keys: $CURRENT_DIR
# mkdir $CURRENT_DIR

SEED_PHRASE=$($TONOS_CLI -u $NETWORK genphrase | grep phrase | cut -c 14-110 ) #| tr -d \")
# SEED_PHRASE=$(tonos-cli genphrase | grep phrase | cut -c 14-110)
# SEED_PHRASE_=${$SEED_PHRASE/"\""/}
# echo $SEED_PHRASE

# mkdir $CURRENT_DIR/RootA
# $TONOS_CLI -u $NETWORK getkeypair $CURRENT_DIR/RootA/deploy.keys.json $SEED_PHRASE #"there screen toddler confirm spring future grief loan wait ready accuse card" # $SEED_PHRASE #| grep Succeeded | cut -c 1-15
# tonos-cli getkeypair ./addrsAndKeys/RootA/deploy.keys.json "age rescue knock load gaze erupt zoo elevator romance basic polar august" | grep Succeeded | cut -c 1-15

WTON_ADDR=$($TONOS_CLI -u $NETWORK genaddr ../$CONTRACTS/TONwrapper.tvc ../$CONTRACTS/TONwrapper.abi.json --genkey $CURRENT_DIR/WTON/deploy.keys.json --wc 0 | grep "Raw address:" | cut -c 14-)
# tonos-cli genaddr ../DEXrootAndWalletcompile/RootTokenContract.tvc ../DEXrootAndWalletcompile/RootTokenContract.abi.json --genkey ./addrsAndKeys/2021-04-12-150601/RootA/deploy.keys.json --wc 0
echo { \"address\": \"$WTON_ADDR\"} > $CURRENT_DIR/WTON/address.json



# WTON_ADDR=$($TONOS_CLI -u $NETWORK genaddr ../$CONTRACTS/RootTokenContract.tvc ../$CONTRACTS/RootTokenContract.abi.json --genkey $CURRENT_DIR/WTON/deploy.keys.json --wc 0 | grep "Raw address:" | cut -c 14-)
# tonos-cli genaddr ../DEXrootAndWalletcompile/RootTokenContract.tvc ../DEXrootAndWalletcompile/RootTokenContract.abi.json --genkey ./addrsAndKeys/2021-04-12-150601/RootA/deploy.keys.json --wc 0

# echo { \"address\": \"$WTON_ADDR\"} > $CURRENT_DIR/WTON/address.json



ROOT_WTON_ADDR=$($TONOS_CLI -u $NETWORK genaddr ../$CONTRACTS/RootTokenContract.tvc ../$CONTRACTS/RootTokenContract.abi.json --genkey $CURRENT_DIR/RootWTON/deploy.keys.json --wc 0 | grep "Raw address:" | cut -c 14-)
# tonos-cli genaddr ../DEXrootAndWalletcompile/RootTokenContract.tvc ../DEXrootAndWalletcompile/RootTokenContract.abi.json --genkey ./addrsAndKeys/2021-04-12-150601/RootA/deploy.keys.json --wc 0
echo { \"address\": \"$ROOT_WTON_ADDR\"} > $CURRENT_DIR/RootWTON/address.json




echo Waiting. Transaction from Giver...

if [ $NETWORK = "http://127.0.0.1" ]
then
    GIVER_RESULT=$($TONOS_CLI -u $NETWORK call 0:841288ed3b55d9cdafa806807f02a0ae0c169aa5edfe88a789a6482429756a94 sendGrams "{\"dest\":\"$WTON_ADDR\",\"amount\":\"100000000000\"}" --abi ./local_giver.abi.json | grep "Succeeded" | cut -c 1-)
elif [ $NETWORK = "https://net.ton.dev" ]
then
    GIVER_RESULT=$($TONOS_CLI -u $NETWORK call 0:2225d70ebde618b9c1e3650e603d6748ee6495854e7512dfc9c287349b4dc988 pay '{"addr":"'$WTON_ADDR'"}' --abi ./giver.abi.json  | grep "Succeeded" | cut -c 1-)
fi

echo Result transaction from Giver: $GIVER_RESULT
echo WTON ADDR: $WTON_ADDR



echo Waiting. Transaction from Giver...

if [ $NETWORK = "http://127.0.0.1" ]
then
    GIVER_RESULT=$($TONOS_CLI -u $NETWORK call 0:841288ed3b55d9cdafa806807f02a0ae0c169aa5edfe88a789a6482429756a94 sendGrams "{\"dest\":\"$ROOT_WTON_ADDR\",\"amount\":\"100000000000\"}" --abi ./local_giver.abi.json | grep "Succeeded" | cut -c 1-)
elif [ $NETWORK = "https://net.ton.dev" ]
then
    GIVER_RESULT=$($TONOS_CLI -u $NETWORK call 0:2225d70ebde618b9c1e3650e603d6748ee6495854e7512dfc9c287349b4dc988 pay '{"addr":"'$ROOT_WTON_ADDR'"}' --abi ./giver.abi.json  | grep "Succeeded" | cut -c 1-)
fi

echo Result transaction from Giver: $GIVER_RESULT
echo ROOT WTON ADDR: $ROOT_WTON_ADDR


# ROOT_ADDR_COMPILE=$(cat $ROOT_ADDR | grep address | cut -c 17-80)
# ROOT_WTON_ADDR=0x$ROOT_WTON_ADDR_

# $DIR=(date +"%Y-%m-%d-%k%M%S")
# mkdir ./addrsAndKeys/$DIR

# $SEED_PHRASE=($TONOS_CLI -u $NETWORK genphrase | grep phrase | cut -c 14-110)
# (tonos-cli genphrase | grep phrase | cut -c 14-110)

# mkdir ./addrsAndKeys/$DIR/WTON
# $TONOS_CLI -u $NETWORK getkeypair ./addrsAndKeys/$DIR/WTON/deploy.keys.json $SEED_PHRASE | grep Succeeded | cut -c 1-15
# tonos-cli getkeypair ./addrsAndKeys/RootA/deploy.keys.json "age rescue knock load gaze erupt zoo elevator romance basic polar august" | grep Succeeded | cut -c 1-15


# ROOT_ADDR1=0:d3245095ffbbf9e39d922833a018b17553971af25ae39205198ec418c34aafa3

# $TONOS_CLI -u $NETWORK call $GIVER sendGrams "{\"dest\":\"$ROOT_ADDR1\",\"amount\":\"$AMOUNT_TONS\"}" --abi ./local_giver.abi.json > /dev/null

# ROOT_ADDR2=0:366ac7ca9a78e466b5097203a314e58874655b946e26d52aa24cda3a6feb8e48
# $TONOS_CLI -u $NETWORK call $GIVER sendGrams "{\"dest\":\"$ROOT_ADDR2\",\"amount\":\"$AMOUNT_TONS\"}" --abi ./local_giver.abi.json > /dev/null
# echo ========================================================================
# echo Deploy wrapped TON
# echo WTON: $ROOT_ADDR


# # ROOT_ADDR3=0:366ac7ca9a78e466b5097203a314e58874655b946e26d52aa24cda3a6feb8e48
# $TONOS_CLI -u $NETWORK call $GIVER sendGrams "{\"dest\":\"$ROOT_WTON_ADDR\",\"amount\":\"$AMOUNT_TONS\"}" --abi ./local_giver.abi.json > /dev/null

# echo ROOT_WTON: $ROOT_WTON_ADDR
# $TONOS_CLI -u $NETWORK account $ROOT_ADDR 

    #   { "name":"name", "type":"bytes" },
    # { "name":"symbol", "type":"bytes" },
    # { "name":"decimals", "type":"uint8" },
    # { "name":"root_public_key", "type":"uint256" },
    # { "name":"root_owner", "type":"uint256" },
    # { "name":"wallet_code", "type":"cell" },
    # { "name":"total_supply", "type":"uint128" }

# ROOT_DATA='{"name":"'$ROOT_NAME'","symbol":"'$ROOT_SYMBOL'","decimals":"'$ROOT_DECIMALS'","root_public_key":"0x'$ROOT_OWNER_PK'","root_owner":"'$ROOT_OWNER'","wallet_code":"'$ROOT_CODE'","total_supply":"'$TOTAL_SUPPLY'"}'
# '{"name":"${nameRootTokenHex}","symbol":"${symbolRootTokenHex}", "decimals":"${decimals}","root_public_key":"0x${contractKeysPublic}", "root_owner":"${root_owner}", "wallet_code":"'${TVM_WALLET_CODE.TVM_WALLET_CODE}'","total_supply":"${total_supply}"}'

# INNER_ADDRES=$($TONOS_CLI -u $NETWORK deploy ./TONwrapperDone.tvc {} --abi ./TONwrapperDone.abi.json --sign ./RootWTON/deploy.keys.json --wc 0 | awk '/"account_address": /' | cut -c 25-90) #| awk '/Transaction /'
# echo $INNER_ADDRES

# $TONOS_CLI -u $NETWORK call $GIVER sendGrams "{\"dest\":\"$INNER_ADDRES\",\"amount\":\"$AMOUNT_TONS\"}" --abi ./local_giver.abi.json > /dev/null
# $TONOS_CLI -u $NETWORK deploy ./TONwrapperDone.tvc $ROOT_DATA --abi ./TONwrapperDone.abi.json --sign ./RootWTON/deploy.keys.json --wc 0 #| awk '/Transaction /'

echo Waiting. Deploy Root from Blockchain...

RESULT_DEPLOY=$($TONOS_CLI -u $NETWORK deploy --abi ../$CONTRACTS/TONwrapper.abi.json --sign $CURRENT_DIR/WTON/deploy.keys.json ../$CONTRACTS/TONwrapper.tvc '{"rootWrappedTON":"'$ROOT_WTON_ADDR'"}' --wc 0 | grep "Transaction" | cut -c 12-) 
echo Status Deploy: $RESULT_DEPLOY

# $TONOS_CLI -u $NETWORK deploy --abi ./WTON/TONwrapper.abi.json --sign ./WTON/deploy.keys.json ./WTON/TONwrapper.tvc '{"rootWrappedTON":"'$ROOT_ADDR'"}' --wc 0 

# $TONOS_CLI -u $NETWORK account $ROOT_ADDR

ACCOUNT_STATUS=$($TONOS_CLI -u $NETWORK account $ROOT_WTON_ADDR | grep "acc_type:" | cut -c 10-)
echo Status Root WTON: $ACCOUNT_STATUS

ACCOUNT_STATUS=$($TONOS_CLI -u $NETWORK account $WTON_ADDR | grep "acc_type:" | cut -c 10-)
echo Status WTON: $ACCOUNT_STATUS
# $TONOS_CLI -u $NETWORK account $INNER_ADDRES 
# ./tonos-cli run ${rawAddress} getName {} --abi RootTokenContract.abi
# ./tonos-cli run ${rawAddress} getSymbol {} --abi RootTokenContract.abi
# ./tonos-cli run ${rawAddress} getDecimals {} --abi RootTokenContract.abi 
# ./tonos-cli run ${rawAddress} getRootKey {} --abi RootTokenContract.abi
# ./tonos-cli run ${rawAddress} getTotalSupply {} --abi RootTokenContract.abi
# ./tonos-cli run ${rawAddress} getWalletCode {} --abi RootTokenContract.abi
# ./tonos-cli run ${rawAddress} getTotalGranted {} --abi RootTokenContract.abi
# ./tonos-cli account ${rawAddress}