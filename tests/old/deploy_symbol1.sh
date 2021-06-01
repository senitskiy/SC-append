#!/bin/sh

# ================================================================================
#
AMOUNT_TONS=60000000000
GIVER="0:841288ed3b55d9cdafa806807f02a0ae0c169aa5edfe88a789a6482429756a94"
CODE=$(./tvm_linker decode --tvc ../contracts/TTW_FT.tvc  | grep code: | cut -c 8-)
KEYS_FILE="keysRTW1.json"
PUBKEY=$(cat $KEYS_FILE | grep public | cut -c 14-77)
ZERO_ADDRESS="0:0000000000000000000000000000000000000000000000000000000000000000"

NETWORK=$(./get_url.sh)

echo "===================================================================================================="
echo "deploying RTW $1"
echo "===================================================================================================="
RTW_ADDRESS=$(./get_rtw1_address.sh)
echo "RTW ADDRESS: $RTW_ADDRESS"

echo "Giving $AMOUNT_TONS TONs to $RTW_ADDRESS"
# ./tonos-cli -u $NETWORK call --abi ./local_giver.abi.json $GIVER sendGrams "{\"dest\":\"$RTW_ADDRESS\",\"amount\":\"$AMOUNT_TONS\"}" > /dev/null
./tonos-cli -u $NETWORK call $GIVER sendGrams "{\"dest\":\"$RTW_ADDRESS\",\"amount\":\"$AMOUNT_TONS\"}" --abi ./local_giver.abi.json > /dev/null

# Transaction succeeded.
# Contract deployed at address: 0:1a75902137ee3ed44cdd60a58fb40b799e788a08ab7d5630c89817eb03d0b91e
# | awk '/Transaction /'

./tonos-cli -u $NETWORK deploy ../contracts/RTW_FT.tvc '{}' --abi ../contracts/RTW_FT.abi.json --sign $KEYS_FILE --wc 0 | awk '/Contract/'
# ./tonos-cli -u $NETWORK account 0:841288ed3b55d9cdafa806807f02a0ae0c169aa5edfe88a789a6482429756a94
deploy_ttw () {
    echo "===================================================================================================="
    echo "deploying TTW 1"
    echo "===================================================================================================="
    LOCAL_KEYS=$1
    LOKAL_PK=$(cat $LOCAL_KEYS | grep public | cut -c 14-77)
    ./tonos-cli -u $NETWORK call --abi ../contracts/RTW_FT.abi.json $RTW_ADDRESS deployWallet '{"tokens":100000000000000000,"grams":"1000000000","walletPublicKey":"0x'$LOKAL_PK'","ownerAddress":"'$ZERO_ADDRESS'"}' --sign $KEYS_FILE | awk '/Result: {/,/}/'
}

deploy_ttw "keys1.json"
deploy_ttw "keys2.json"
deploy_ttw "keys3.json"
deploy_ttw "keys4.json"
deploy_ttw "keys5.json"