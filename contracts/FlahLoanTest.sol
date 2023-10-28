pragma solidity >=0.5.0;


import "../node_modules/openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "../node_modules/openzeppelin-solidity/contracts/utils/math/SafeMath.sol";
import "../node_modules/openzeppelin-solidity/contracts/access/Ownable.sol";
import "./base/FlashLoanReceiverBase.sol";
import "./interfaces/ILendingPool.sol";
import "./interfaces/ILendingPoolAddressesProvider.sol";
import "./pancakeSwap/PancakeRouterV2.sol";
import "./WBNB.sol";

contract flashLoanContractTest is Ownable, FlashLoanReceiverBase(address(0x78547CBf195Dc3D92C5847acD9E89aFB35430c0f)) {

    using SafeMath for uint256;

    // testnet address of the pancake router
    address routerAddress = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    // testnet BNB ADDRESS
    address bnbAddress;
    address WBNBAddress;
    uint deadline = 5;
    address pairA;
    address pairB;
    address pairC;
    uint256 pairAValue;
    uint256 pairBValue;
    uint256 pairCValue;
    uint256 InitGasCost;
    uint256 minimumProfit;
    address[] dynamicPathArray;
    bool currentIsTesting;

    constructor(address mainBNBAddress, address mainWBNBAddress){
        bnbAddress = mainBNBAddress;
        WBNBAddress = mainWBNBAddress;
    }

    event SwapDone(
        address indexed a,
        address indexed b,
        address indexed c,
        uint256 am,
        uint256 bm,
        uint256 cm
    );

    event LoanTaken(
        address token,
        uint256 value,
        uint256 fee
    );

    event LoanPayed(
        address token,
        uint256 value,
        uint256 fee
    );

    Router pancakeRouterV2 = Router(routerAddress);


    function directTokenSwap(uint256 minimumProfit, uint256 _amount, uint256 _fee, bool test) internal{
        uint256 earlyFirstBalance = ERC20(pairA).balanceOf(address(this));
        address[] memory longPath = new address[](4);
        longPath[0]=pairA;
        longPath[1]=pairB;
        longPath[2]=pairC;
        longPath[3]=pairA;
        pancakeRouterV2.swapExactTokensForTokens(_amount, pairAValue, longPath, address(this), block.timestamp+deadline);
        emit SwapDone(pairA,pairB,pairC,pairAValue,pairBValue,pairCValue);

        uint256 lateFirstBalance = ERC20(pairA).balanceOf(address(this));

        require(lateFirstBalance > earlyFirstBalance.add(minimumProfit).add(_fee), "didn't make a profit at all");

        if(currentIsTesting){
            revert("Testing Is Done, the operation was profitable");
        }
    }
    function DynamicPathWBNBBridgedSwap(uint256 _amount, uint256 _fee, bool test) internal {
        emit LoanTaken(pairA,_amount,_fee);

        require(dynamicPathArray.length > 0, "Path array is empty");
        // Buy WBNB with loaned BNB

        WBNB(WBNBAddress).deposit{value:_amount, gas:50000}();
        WBNB(WBNBAddress).approve(routerAddress,_amount);

        // check the balance of WBWB of the contract wallet
        uint256 earlyFirstBalance = ERC20(WBNBAddress).balanceOf(address(this));

        address[] memory longPath = new address[](dynamicPathArray.length +2);
        longPath[0]=WBNBAddress;
        for (uint i=0; i<dynamicPathArray.length; i++){
            longPath[i+1] = dynamicPathArray[i];
        }
        longPath[dynamicPathArray.length+1]=WBNBAddress;

        // Long path swaps execution
        pancakeRouterV2.swapExactTokensForTokens(_amount, pairAValue, longPath, address(this), block.timestamp+deadline);

        emit SwapDone(pairA,pairB,pairC,pairAValue,pairBValue,pairCValue);

        // reChecking the balance of WBWB of the contract wallet after swap
        uint256 lateFirstBalance = ERC20(WBNBAddress).balanceOf(address(this));

        // Profit calculation
        require(lateFirstBalance > earlyFirstBalance.add(InitGasCost).add(_fee), "didn't make a profit at all");

        WBNB(WBNBAddress).withdraw(lateFirstBalance);


        if(currentIsTesting){
            revert("Testing Is Done, the operation was profitable");
        }

    }


    function DynamicPathWBNBBridgedSingleStepSwap(uint256 _amount, uint256 _fee, bool test) internal {
        emit LoanTaken(pairA,_amount,_fee);

        require(dynamicPathArray.length > 0, "Path array is empty");
        // Buy WBNB with loaned BNB

        WBNB(WBNBAddress).deposit{value:_amount, gas:50000}();
        WBNB(WBNBAddress).approve(routerAddress,_amount);

        // check the balance of WBWB of the contract wallet
        uint256 earlyFirstBalance = ERC20(WBNBAddress).balanceOf(address(this));

        address[] memory longPath = new address[](dynamicPathArray.length +2);
        longPath[0]=WBNBAddress;
        for (uint i=0; i<dynamicPathArray.length; i++){
            longPath[i+1] = dynamicPathArray[i];
        }
        longPath[dynamicPathArray.length+1]=WBNBAddress;

        //Step by step execution
        uint256[] memory amountOuts = new uint[](longPath.length);
        amountOuts[0] = _amount;
        for (uint i=0; i<longPath.length - 1; i++){
            address[] memory path = new address[](2);
            path[0]=longPath[i] ;
            path[1]=longPath[i + 1];
            uint256[] memory amountsOut = pancakeRouterV2.getAmountsOut(amountOuts[i], path);
            ERC20(longPath[i]).approve(routerAddress,amountsOut[0]);
            uint256 slippedAmount = uint256(amountsOut[1]).mul(988).div(1000);
            pancakeRouterV2.swapExactTokensForTokensSupportingFeeOnTransferTokens(amountsOut[0], 0, path, address(this), block.timestamp+deadline);
            //uint[] memory afterSwapAmounts = pancakeRouterV2.swapExactTokensForTokens(amountsOut[0], amountsOut[1], path, address(this), block.timestamp+deadline);
            if(i+1 < longPath.length){
                uint256 nextBalance = ERC20(longPath[i + 1]).balanceOf(address(this));
                amountOuts[i+1] = nextBalance < amountsOut[1] ? nextBalance : amountsOut[1];
            }
        }

        emit SwapDone(pairA,pairB,pairC,pairAValue,pairBValue,pairCValue);

        // reChecking the balance of WBWB of the contract wallet after swap
        uint256 lateFirstBalance = ERC20(WBNBAddress).balanceOf(address(this));

        // Profit calculation
        require(lateFirstBalance > earlyFirstBalance.add(InitGasCost).add(_fee), "didn't make a profit at all");

        WBNB(WBNBAddress).withdraw(lateFirstBalance);


        if(currentIsTesting){
            revert("Testing Is Done, the operation was profitable");
        }

    }

    function DynamicPathWBNBBridgedSwapWithFees(uint256 _amount, uint256 _fee, bool test) internal {
        emit LoanTaken(pairA,_amount,_fee);

        require(dynamicPathArray.length > 0, "Path array is empty");
        // Buy WBNB with loaned BNB

        WBNB(WBNBAddress).deposit{value:_amount, gas:50000}();
        WBNB(WBNBAddress).approve(routerAddress,_amount);

        // check the balance of WBWB of the contract wallet
        uint256 earlyFirstBalance = ERC20(WBNBAddress).balanceOf(address(this));

        address[] memory longPath = new address[](dynamicPathArray.length +2);
        longPath[0]=WBNBAddress;
        for (uint i=0; i<dynamicPathArray.length; i++){
            longPath[i+1] = dynamicPathArray[i];
        }
        longPath[dynamicPathArray.length+1]=WBNBAddress;

        // Long path swaps execution
        pancakeRouterV2.swapExactTokensForTokensSupportingFeeOnTransferTokens(_amount, pairAValue, longPath, address(this), block.timestamp+deadline);

        emit SwapDone(pairA,pairB,pairC,pairAValue,pairBValue,pairCValue);

        // reChecking the balance of WBWB of the contract wallet after swap
        uint256 lateFirstBalance = ERC20(WBNBAddress).balanceOf(address(this));

        // Profit calculation
        require(lateFirstBalance > earlyFirstBalance.add(InitGasCost).add(_fee), "didn't make a profit at all");

        WBNB(WBNBAddress).withdraw(lateFirstBalance);


        if(currentIsTesting){
            revert("Testing Is Done, the operation was profitable");
        }

    }

    function WBNBBridgedSwap(uint256 _amount, uint256 _fee, bool test) internal {
        emit LoanTaken(pairA,_amount,_fee);

        // Buy WBNB with loaned BNB

        WBNB(WBNBAddress).deposit{value:_amount, gas:50000}();
        WBNB(WBNBAddress).approve(routerAddress,_amount);

        // check the balance of WBWB of the contract wallet
        uint256 earlyFirstBalance = ERC20(WBNBAddress).balanceOf(address(this));

        address[] memory longPath = new address[](6);
        longPath[0]=WBNBAddress;
        longPath[1]=pairA;
        longPath[2]=pairB;
        longPath[3]=pairC;
        longPath[4]=pairA;
        longPath[5]=WBNBAddress;

        // Long path swaps execution
        pancakeRouterV2.swapExactTokensForTokens(_amount, pairAValue, longPath, address(this), block.timestamp+deadline);

        emit SwapDone(pairA,pairB,pairC,pairAValue,pairBValue,pairCValue);

        // reChecking the balance of WBWB of the contract wallet after swap
        uint256 lateFirstBalance = ERC20(WBNBAddress).balanceOf(address(this));

        // Profit calculation
        require(lateFirstBalance > earlyFirstBalance.add(InitGasCost).add(_fee), "didn't make a profit at all");

        WBNB(WBNBAddress).withdraw(lateFirstBalance);


        if(currentIsTesting){
            revert("Testing Is Done, the operation was profitable");
        }

    }

    function  executeOperation (
        address _reserve,
        uint256 _amount,
        uint256 _fee,
        bytes calldata _params
    )
    external override
    {
        require(_amount <= getBalanceInternal(address(this), _reserve), "Invalid balance, was the flashLoan successful?");

        emit LoanTaken(pairA,_amount,_fee);

        // Time to transfer the funds back
        uint totalDebt = _amount.add(_fee);
        transferFundsBackToPoolInternal(_reserve, totalDebt);
    }

    function getFlashLoan(address loanToken, uint256 amount, bytes memory data) public onlyOwner {
        address asset = address(loanToken);
        ILendingPool lendingPool = ILendingPool(addressesProvider.getLendingPool());
        lendingPool.flashLoan(address(this), asset, amount, data);
    }


    function executeSwaps(
        uint256 bnbAmount
    ) public onlyOwner {
        getFlashLoan(bnbAddress, bnbAmount, "");

    }


    function withdraw(address _to, uint256 _amount) onlyOwner public{
        uint256 balance = address(this).balance;
        require(_amount < balance, "you can't withdraw more than your balance");
        require(_to != address(0), "you must assign an address to send to");
        (bool success, ) = _to.call{value:_amount}("");
        require(success, "Transfer failed. try again later");
    }

    function withdrawToken(address _to, uint256 _amount, address _token) onlyOwner public{
        require(_to != address(0), "you must assign an address to send to");
        require(_token != address(0), "you must assign a token adddress");
        uint256 lateFirstBalance = ERC20(_token).balanceOf(address(this));
        require(_amount < lateFirstBalance, "you can't withdraw more than your balance");
        bool success = ERC20(_token).transfer(_to, _amount);
        require(success, "Transfer failed. try again later");
    }


    function decode(bytes memory data) public pure returns (uint a, bool b) {
        assembly {
            a := mload(
                add(
                    data,
                    32
                )
            )

            b := mload(
                add(
                    data,
                    8
                )
            )

        }
    }


}
