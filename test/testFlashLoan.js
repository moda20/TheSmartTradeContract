const smartTrade = artifacts.require("smartTrade");
const flashLoanTEst = artifacts.require("flashLoanContractTest");
const routerContract = artifacts.require("Router");

const addresses={
    dai:"0x8a9424745056eb399fd19a0ec26a14316684e274",
    busd:"0x78867bbeef44f2326bf8ddd1941a4439382ef2a7",
    eth:"0x8babbb98678facc7342735486c851abd7a0d17ca",
    usdt:"0x7ef95a0fee0dd31b22626fa2e10ee6a223f8a684"
}

const pairA = web3.utils.toChecksumAddress(addresses.usdt);
const pairB = web3.utils.toChecksumAddress(addresses.busd);
const pairC = web3.utils.toChecksumAddress(addresses.eth);

const amount  = web3.utils.toBN(web3.utils.toWei('0.001'))
const bnbAmount = amount.mul(web3.utils.toBN(1200));
const pairAValue = amount.mul(web3.utils.toBN(1000));
const pairBValue = amount.mul(web3.utils.toBN(2000));
const pairCValue = amount.mul(web3.utils.toBN(1500));

//const PancakeRouterV2 = "0xD99D1c33F9fC3444f8101754aBC46c52416550D1"; // this router is an old router i used to work with
const PancakeRouterV2 = "0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3";
const WBNBAddress = "0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd";
module.exports = async done => {
    try {
        //let newAccount = web3.eth.accounts.create();
        const flashLoanTEstInstance = await flashLoanTEst.deployed();
            let results = await flashLoanTEstInstance.executeSwaps(
                web3.utils.toBN(23556336481938520),
            );
        console.log(results)
        /*const [admin, _] = await web3.eth.getAccounts();
        const router = await Router.at(ROUTER_ADDRESS);
        const weth = await Weth.at(WETH_ADDRESS);
        const dai = await Dai.at(DAI_ADDRESS);

        await weth.deposit({value: amountIn})
        await weth.approve(router.address, amountIn);

        const amountsOut = await router.getAmountsOut(amountIn, [WETH_ADDRESS, DAI_ADDRESS]);
        const amountOutMin = amountsOut[1]
            .mul(web3.utils.toBN(90))
            .div(web3.utils.toBN(100));
        const balanceDaiBefore = await dai.balanceOf(admin);

        await router.swapExactTokensForTokens(
            amountIn,
            amountOutMin,
            [WETH_ADDRESS, DAI_ADDRESS],
            admin,
            Math.floor((Date.now() / 1000)) + 60 * 10
        );

        const balanceDaiAfter = await dai.balanceOf(admin);
        const executionPerf = balanceDaiAfter.sub(balanceDaiBefore).div(amountsOut[1]);
        console.log(executionPerf.toString());*/
    } catch(e) {
        console.log(e);
    }
    done();
};
