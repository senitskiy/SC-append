#!/bin/sh

# ================================================================================
#
# CONTRACTS="DEX-core-smart-contracts"
# CONTRACTS="DEXrootAndWalletcompile"
# echo $CONTRACTS
# echo Directory SC: $CONTRACTS

DIR=$(date +"%Y-%m-%d-%k%M%S" | cut -c 1-17)
CURRENT_DIR="./addrsAndKeys/"${DIR}
# echo Directory Address and keys: $CURRENT_DIR
mkdir $CURRENT_DIR

echo "#!/bin/sh \n" > ./configes/get_current_dir.sh
echo "echo ${CURRENT_DIR}" >> ./configes/get_current_dir.sh
# echo -en \#!/bin/sh \n echo ${CURRENT_DIR} > ./configes/get_current_dir.sh
echo $CURRENT_DIR