const { abiContract } = require("@tonclient/core");
const { ResponseType } = require("@tonclient/core/dist/bin");
const { converter } = require('hex2dec');

const {
    signerKeys,
    signerNone,
    TonClient,
    MessageBodyType,
} = require("@tonclient/core");

const { libNode } = require("@tonclient/lib-node");

TonClient.useBinaryLibrary(libNode);
TonClient.defaultConfig = { network: { endpoints: ["http://localhost"] } };

const { NewContract } = require("./contracts");

// Address of giver on TON OS SE
const giverAddress = '0:b5e9240fc2d2f1ff8cbb1d1dee7fb7cae155e5f6320e585fcc685698994a19a5';

// Giver ABI on TON OS SE
const giverAbi = abiContract({
    'ABI version': 2,
    header: ['time', 'expire'],
    functions: [
        {
            name: 'sendTransaction',
            inputs: [
                { 'name': 'dest', 'type': 'address' },
                { 'name': 'value', 'type': 'uint128' },
                { 'name': 'bounce', 'type': 'bool' }
            ],
            outputs: []
        },
        {
            name: 'getMessages',
            inputs: [],
            outputs: [
                {
                    components: [
                        { name: 'hash', type: 'uint256' },
                        { name: 'expireAt', type: 'uint64' }
                    ],
                    name: 'messages',
                    type: 'tuple[]'
                }
            ]
        },
        {
            name: 'upgrade',
            inputs: [
                { name: 'newcode', type: 'cell' }
            ],
            outputs: []
        },
        {
            name: 'constructor',
            inputs: [],
            outputs: []
        }
    ],
    data: [],
    events: []
});

// Requesting 10 local test tokens from TON OS SE giver
async function get_tokens_from_giver(client, account) {
    const giverKeyPair = {
        "public": "2ada2e65ab8eeab09490e3521415f45b6e42df9c760a639bcf53957550b25a16",
        "secret": "172af540e43a524763dd53b26a066d472a97c4de37d5498170564510608250c3"
    };

    const params = {
        send_events: false,
        message_encode_params: {
            address: giverAddress,
            abi: giverAbi,
            call_set: {
                function_name: 'sendTransaction',
                input: {
                    dest: account,
                    value: 10_000_000_000,
                    bounce: false
                }
            },
            signer: {
                type: 'Keys',
                keys: giverKeyPair
            },
        },
    }
    await client.processing.process_message(params)
}

/**
 * @param text {string}
 * @returns {Promise<{address:string, signer: Signer}>}
 */
async function deployNew(nameStr) { //, symbolStr, nameBt, symbolBt
    const signer = signerKeys(await TonClient.default.crypto.generate_random_sign_keys());
    const deployParams = {
        abi: abiContract(NewContract.abi),
        deploy_set: {
            tvc: NewContract.tvc,
        },
        call_set: {
            function_name: "constructor",
            input: {
                // text: Buffer.from(text).toString("hex"),
                nameStr: Buffer.from(nameStr).toString("hex"),
                // symbolStr: Buffer.from(symbolStr).toString("hex"),
                // nameBt: nameBt,     //Buffer.from(text).toString("hex"),
                // symbolBt: symbolBt,     //Buffer.from(text).toString("hex"),                
            },
        },
        signer
    };
    const address = (await TonClient.default.abi.encode_message(deployParams)).address;
    await get_tokens_from_giver(TonClient.default, address);
    await TonClient.default.processing.process_message({
        message_encode_params: deployParams,
        send_events: false,
    });
    return { address, signer };
}

/**
 * @param address {string}
 * @param signer {Signer}
 * @param text {string}
 * @returns {Promise<void>}
 */
async function setHelloText(address, signer, text) {
    await TonClient.default.processing.process_message({
        message_encode_params: {
            abi: abiContract(NewContract.abi),
            call_set: {
                function_name: "setHelloText",
                input: {
                    Symbol: Buffer.from(text).toString("hex"),
                },
            },
            signer,
            address,
        },
        send_events: false,
    });
}

async function addSymbol(address, signer, text) {
    await TonClient.default.processing.process_message({
        message_encode_params: {
            abi: abiContract(NewContract.abi),
            call_set: {
                function_name: "addSymbol",
                input: {
                    text: Buffer.from(text).toString("hex"), //"77544f4e"
                },
            },
            signer,
            address,
        },
        send_events: false,
    });
}

async function complexSymbol(address, signer, rootA, rootB) {
    await TonClient.default.processing.process_message({
        message_encode_params: {
            address: address,
            signer: signerNone(),
            abi: abiContract(NewContract.abi),
            call_set: {
                function_name: "complexSymbol",
                input: {
                    rootA: rootA, 
                    rootB: rootB
                },
            },
        },
        send_events: false,
    });
}

/**
 *
 * @returns {Promise<string>}
 */
async function getHelloText(address) {
    const account = (await TonClient.default.net.wait_for_collection({
        collection: "accounts",
        filter: { id: { eq: address } },
        result: "boc"
    })).result.boc;
    const abi = abiContract(NewContract.abi);
    const { decoded } = await TonClient.default.tvm.run_tvm({
        abi,
        account,
        message: (await TonClient.default.abi.encode_message({
            address: address,
            signer: signerNone(),
            abi,
            call_set: {
                function_name: "getHelloText",
                input: {},
            }
        })).message
    });
    return Buffer.from(decoded.output.text, "hex").toString();
}

async function getSymbolString(address) {
    const account = (await TonClient.default.net.wait_for_collection({
        collection: "accounts",
        filter: { id: { eq: address } },
        result: "boc"
    })).result.boc;
    const abi = abiContract(NewContract.abi);
    const { decoded } = await TonClient.default.tvm.run_tvm({
        abi,
        account,
        message: (await TonClient.default.abi.encode_message({
            address: address,
            signer: signerNone(),
            abi,
            call_set: {
                function_name: "getSymbolString",
                input: {},
            }
        })).message
    });
    return Buffer.from(decoded.output.text, "hex").toString();
}

async function getNameString(address) {
    const account = (await TonClient.default.net.wait_for_collection({
        collection: "accounts",
        filter: { id: { eq: address } },
        result: "boc"
    })).result.boc;
    const abi = abiContract(NewContract.abi);
    const { decoded } = await TonClient.default.tvm.run_tvm({
        abi,
        account,
        message: (await TonClient.default.abi.encode_message({
            address: address,
            signer: signerNone(),
            abi,
            call_set: {
                function_name: "getNameString",
                input: {},
            }
        })).message
    });
    return Buffer.from(decoded.output.text, "hex").toString();
}

async function getSymbolBytes(address) {
    const account = (await TonClient.default.net.wait_for_collection({
        collection: "accounts",
        filter: { id: { eq: address } },
        result: "boc"
    })).result.boc;
    const abi = abiContract(NewContract.abi);
    const { decoded } = await TonClient.default.tvm.run_tvm({
        abi,
        account,
        message: (await TonClient.default.abi.encode_message({
            address: address,
            signer: signerNone(),
            abi,
            call_set: {
                function_name: "getSymbolBytes",
                input: {},
            }
        })).message
    });
    return Buffer.from(decoded.output.text, "hex").toString();
}

async function getNameBytes(address) {
    const account = (await TonClient.default.net.wait_for_collection({
        collection: "accounts",
        filter: { id: { eq: address } },
        result: "boc"
    })).result.boc;
    const abi = abiContract(NewContract.abi);
    const { decoded } = await TonClient.default.tvm.run_tvm({
        abi,
        account,
        message: (await TonClient.default.abi.encode_message({
            address: address,
            signer: signerNone(),
            abi,
            call_set: {
                function_name: "getNameBytes",
                input: {},
            }
        })).message
    });
    return Buffer.from(decoded.output.text, "hex").toString();
}
(async () => {
    try {//"name":"77726170706564544f4e","symbol":"77544f4e" nameStr, symbolStr, nameBt, symbolBt)
        const { address, signer } = await deployNew("wrappedTON")//, "wTON", "77726170706564544f4e", "77544f4e")//("Hello World!");
        // console.log(`Initial hello text is "${await getHelloText(address)}"`);

        // const accountSubscription = await TonClient.default.net.subscribe_collection({
        //     collection: "accounts",
        //     filter: { id: { eq: address } },
        //     result: "balance",
        // }, (params, responseType) => {
        //     if (responseType === ResponseType.Custom) {
        //         console.log("Account has updated. Current balance is ", parseInt(params.result.balance));
        //     }
        // });

        // const messageSubscription = await TonClient.default.net.subscribe_collection({
        //     collection: "messages",
        //     filter: {
        //         src: { eq: address },
        //         OR: {
        //             dst: { eq: address },
        //         }
        //     },
        //     result: "boc",
        // }, async (params, responseType) => {
        //     try {
        //         if (responseType === ResponseType.Custom) {
        //             const decoded = (await TonClient.default.abi.decode_message({
        //                 abi: abiContract(HelloEventsContract.abi),
        //                 message: params.result.boc,
        //             }));
        //             switch (decoded.body_type) {
        //             case MessageBodyType.Input:
        //                 console.log(`External inbound message, function "${decoded.name}", parameters: `, JSON.stringify(decoded.value));
        //                 break;
        //             case MessageBodyType.Output:
        //                 console.log(`External outbound message, function "${decoded.name}", result`, JSON.stringify(decoded.value));
        //                 break;
        //             case MessageBodyType.Event:
        //                 console.log(`External outbound message, event "${decoded.name}", parameters`, JSON.stringify(decoded.value));
        //                 break;
        //             }
        //         }
        //     } catch (err) {
        //         console.log('>>>', err);
        //     }
        // });

        // await setHelloText(address, signer, "Hello there!");
        // console.log(`Updated hello text is ${await getHelloText(address)}`);

        console.log(`Updated text is ${await getSymbolString(address)}`);
        await addSymbol(address, signer, "WUSDT");
        console.log(`Updated text is ${await getSymbolString(address)}`);
        await addSymbol(address, signer, "-USDT");
  

        console.log(`Updated text is ${await getSymbolString(address)}`); 

        // console.log(`Updated text is ${await getSymbolBytes(address)}`); 

        console.log(`complexSymbol is ${await complexSymbol(address, signer, "0:5d98b41290707e3e57600c9584ac6c45b79271daabc2dd45e4847b3e0ca8a8ed","0:0fbfab96602abdacd0d28952ccbf6ab2b3c9bac6f1c71cf370d2bec033ac2976")}`);

    } catch (error) {
        console.error(error);
    }
    TonClient.default.close();
})();
