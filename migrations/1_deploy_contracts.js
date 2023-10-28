const SmartTrade = artifacts.require("smartTrade");
const flashLoanTest = artifacts.require("flashLoanContractTest");
const WBNBAddress = "0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c"; // MainNet
const WBNBAddressTestNet = "0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd"; //TestNet
const BNBAddress = "0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE"; // MaiNet
const BNBAddressTestNet = "0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE"; //TestNet


module.exports = function(deployer) {
  console.log(deployer.network)
  switch (deployer.network){
    case "testNetBSC":{
      deployer.deploy(flashLoanTest, BNBAddressTestNet, WBNBAddressTestNet);
      break;
    }
    case "MainNetBsc":{
      deployer.deploy(SmartTrade, BNBAddress, WBNBAddress);
      break;
    }
  }
};
