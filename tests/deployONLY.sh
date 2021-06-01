#!/bin/sh

# ================================================================================
#
NETWORK=$(./configes/get_network.sh)
CONTRACTS=$(./configes/get_contracts.sh)
TVM_LINKER=$(./configes/get_tvm_linker.sh)
TONOS_CLI=$(./configes/get_tonos_cli.sh)
CURRENT_DIR=$(./configes/create_current_dir.sh)

echo Конфигурация запуска:
echo Blockchain:                 $NETWORK
echo Directory contracts:        $CONTRACTS
echo Linker:                     $TVM_LINKER
echo Tonos-cli:                  $TONOS_CLI
echo Directory Address and keys: $CURRENT_DIR
echo ====================================================

./deploy/1_WTON.sh
./deploy/2_Root4WTON.sh
./deploy/3_RootBTC.sh
./deploy/4_RootETH.sh
./deploy/5_RootUSDT.sh
./deploy/6_DEXroot.sh

./deploy/7_setDEXclientCode.sh
./deploy/8_setDEXpairCode.sh
./deploy/9_computeDEXpair.sh

./deploy/10_deploy_client1.sh
# ./deploy/10_deploy_client1__.sh
# ./deploy/deploy9pairA-B.sh
# ./deploy/deploy10pairB-WTON.sh
# ./deploy/deploy11client1.sh
# ./deploy/deploy12client2.sh
# ./deploy/deploy13connect-client1toPairA-B.sh
# ./deploy/_deploy9connect-client1toPairA-B.sh
# ./deploy/deploy14connect-client2toPairA-B.sh
