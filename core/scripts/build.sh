#!/bin/bash
set -e -x

cd `dirname $0`/../../

if [ ! -d "../crypto"];then
        git clone https://github.com/xuperchain/crypto.git ../crypto
fi


# build wasm2c
make -C core/xvm/compile/wabt -j 4
cp core/xvm/compile/wabt/build/wasm2c ./


if [ 0"${XCHAIN_BUILD_DEBUG}" = "01" ]; then
        XCHAIN_CUSTOME_BUILD_GCFLAGS="all=-N -l"
fi

# build framework and tools
function buildpkg() {
    output=$1
    pkg=$2
    buildVersion=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo unknown)
    buildDate=$(date "+%Y-%m-%d-%H:%M:%S")
    commitHash=$(git rev-parse --short HEAD 2>/dev/null || echo unknown)
    go build -o $output -gcflags "${XCHAIN_CUSTOME_BUILD_GCFLAGS}" -ldflags "-X main.buildVersion=$buildVersion -X main.buildDate=$buildDate -X main.commitHash=$commitHash" $pkg
}

buildpkg xchain-cli github.com/xuperchain/xuperchain/core/cmd/cli
buildpkg xchain github.com/xuperchain/xuperchain/core/cmd/xchain
buildpkg xdev github.com/xuperchain/xuperchain/core/cmd/xdev
buildpkg xchain-httpgw github.com/xuperchain/xuperchain/core/gateway
buildpkg dump_chain github.com/xuperchain/xuperchain/core/test
buildpkg relayer github.com/xuperchain/xuperchain/core/cmd/relayer/relayer

# build plugins
echo "OS:"${PLATFORM}
echo "## Build Plugins..."

mkdir -p core/plugins/kv core/plugins/crypto core/plugins/consensus core/plugins/contract

#go build --buildmode=plugin -gcflags "${XCHAIN_CUSTOME_BUILD_GCFLAGS}" -o core/plugins/crypto/crypto-default.so.1.0.0 github.com/xuperchain/xuperchain/core/crypto/client/xchain/plugin_impl
go build --buildmode=plugin -gcflags "${XCHAIN_CUSTOME_BUILD_GCFLAGS}" --tags multi -o core/plugins/kv/kv-ldb-multi.so.1.0.0 github.com/xuperchain/xuperchain/core/kv/kvdb/plugin-ldb
go build --buildmode=plugin -gcflags "${XCHAIN_CUSTOME_BUILD_GCFLAGS}" --tags single -o core/plugins/kv/kv-ldb-single.so.1.0.0 github.com/xuperchain/xuperchain/core/kv/kvdb/plugin-ldb
go build --buildmode=plugin -gcflags "${XCHAIN_CUSTOME_BUILD_GCFLAGS}" --tags cloud -o core/plugins/kv/kv-ldb-cloud.so.1.0.0 github.com/xuperchain/xuperchain/core/kv/kvdb/plugin-ldb
go build --buildmode=plugin -gcflags "${XCHAIN_CUSTOME_BUILD_GCFLAGS}" -o core/plugins/kv/kv-badger.so.1.0.0 github.com/xuperchain/xuperchain/core/kv/kvdb/plugin-badger
#go build --buildmode=plugin -gcflags "${XCHAIN_CUSTOME_BUILD_GCFLAGS}" -o core/plugins/crypto/crypto-default.so.1.0.0 github.com/xuperchain/xuperchain/core/crypto/client/xchain/plugin_impl
#go build --buildmode=plugin -gcflags "${XCHAIN_CUSTOME_BUILD_GCFLAGS}" -o core/plugins/crypto/crypto-schnorr.so.1.0.0 github.com/xuperchain/xuperchain/core/crypto/client/schnorr/plugin_impl
#go build --buildmode=plugin -gcflags "${XCHAIN_CUSTOME_BUILD_GCFLAGS}" -o core/plugins/crypto/crypto-gm.so.1.0.0 github.com/xuperchain/xuperchain/core/crypto/client/gm/gmclient/plugin_impl
go build --buildmode=plugin -gcflags "${XCHAIN_CUSTOME_BUILD_GCFLAGS}" -o core/plugins/consensus/consensus-pow.so.1.0.0 github.com/xuperchain/xuperchain/core/consensus/pow
go build --buildmode=plugin -gcflags "${XCHAIN_CUSTOME_BUILD_GCFLAGS}" -o core/plugins/consensus/consensus-single.so.1.0.0 github.com/xuperchain/xuperchain/core/consensus/single
go build --buildmode=plugin -gcflags "${XCHAIN_CUSTOME_BUILD_GCFLAGS}" -o core/plugins/consensus/consensus-tdpos.so.1.0.0 github.com/xuperchain/xuperchain/core/consensus/tdpos/main
go build --buildmode=plugin -gcflags "${XCHAIN_CUSTOME_BUILD_GCFLAGS}" -o core/plugins/consensus/consensus-xpoa.so.1.0.0 github.com/xuperchain/xuperchain/core/consensus/xpoa/main
go build --buildmode=plugin -gcflags "${XCHAIN_CUSTOME_BUILD_GCFLAGS}" -o core/plugins/p2p/p2p-p2pv1.so.1.0.0 github.com/xuperchain/xuperchain/core/p2p/p2pv1/plugin_impl
go build --buildmode=plugin -gcflags "${XCHAIN_CUSTOME_BUILD_GCFLAGS}" -o core/plugins/p2p/p2p-p2pv2.so.1.0.0 github.com/xuperchain/xuperchain/core/p2p/p2pv2/plugin_impl
go build --buildmode=plugin -gcflags "${XCHAIN_CUSTOME_BUILD_GCFLAGS}" -o core/plugins/xendorser/xendorser-default.so.1.0.0 github.com/xuperchain/xuperchain/core/server/xendorser/plugin-default
go build --buildmode=plugin -gcflags "${XCHAIN_CUSTOME_BUILD_GCFLAGS}" -o core/plugins/xendorser/xendorser-proxy.so.1.0.0 github.com/xuperchain/xuperchain/core/server/xendorser/plugin-proxy

cd ../crypto
go build --buildmode=plugin -o ./output/crypto-default.so.1.0.0 github.com/xuperchain/crypto/client/hdxchain/
cd -
cp ../crypto/output/crypto-default.so.1.0.0 core/plugins/crypto/crypto-default.so.1.0.0


# build output dir
mkdir -p output
output_dir=output
mv xchain-cli xchain ${output_dir}
mv xchain-httpgw ${output_dir}
mv wasm2c ${output_dir}
mv dump_chain ${output_dir}
mv xdev ${output_dir}
mv relayer ${output_dir}
cp -rf core/plugins ${output_dir}
cp -rf core/data ${output_dir}
cp -rf core/conf ${output_dir}
cp -rf core/cmd/relayer/conf/relayer.yaml ${output_dir}/conf
cp -rf core/cmd/cli/conf/* ${output_dir}/conf
cp -rf core/cmd/quick_shell/* ${output_dir}
mkdir -p ${output_dir}/data/blockchain
