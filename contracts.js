const fs = require("fs");
const path = require("path");

const read = name => fs.readFileSync(path.resolve(__dirname, name));
module.exports = {
    NewContract: {
        abi: JSON.parse(read("NewContract.abi.json").toString()),
        tvc: read("NewContract.tvc").toString("base64"),
    }
};

