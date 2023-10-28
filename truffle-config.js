const HDWalletProvider = require("truffle-hdwallet-provider");
const privateTestKey = ""
const privateMainNetKey = ""
const provider = new HDWalletProvider(
    [privateTestKey],
    'https://data-seed-prebsc-2-s3.binance.org:8545/',
    0, 1
);


const MainNetBSCProvider =  new HDWalletProvider(
    [privateMainNetKey],
    'https://bsc-dataseed.binance.org',
    0, 1
);
module.exports = {
  // Uncommenting the defaults below
  // provides for an easier quick-start with Ganache.
  // You can also follow this format for other networks;
  // see <http://truffleframework.com/docs/advanced/configuration>
  // for more details on how to specify configuration options!
  //
  networks: {
      testNetBSC: {
     provider: () => provider,
     network_id: "*",
     from:"0x9F8cB701AA447f4fB5D2C5199F5c67C26C125506",
     gasPrice: 47000000000,
   },
   MainNetBsc: {
     provider: () => MainNetBSCProvider,
     network_id: "*",
     from:"0x2925824eebbb5f374e17cd8da8e82a6a496d9398",
   }
  },
  //
    // Configure your compilers
    compilers: {
        solc: {
            version: "0.8.0",    // Fetch exact version from solc-bin (default: truffle's version)
            // docker: true,        // Use "0.5.1" you've installed locally with docker (default: false)
            // settings: {          // See the solidity docs for advice about optimization and evmVersion
            //  optimizer: {
            //    enabled: false,
            //    runs: 200
            //  },
            //  evmVersion: "byzantium"
            // }
        }
    }
};
