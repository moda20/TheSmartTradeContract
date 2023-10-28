pragma solidity >=0.8.0;

import "../../node_modules/openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "../../node_modules/openzeppelin-solidity/contracts/utils/math/SafeMath.sol";
import "../../node_modules/openzeppelin-solidity/contracts/token/ERC20/utils/SafeERC20.sol";
import "../interfaces/IFlashLoanReceiver.sol";
import "../interfaces/ILendingPoolAddressesProvider.sol";

abstract contract FlashLoanReceiverBase is IFlashLoanReceiver {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    ILendingPoolAddressesProvider public addressesProvider;

    address public constant BNB_ADDRESS = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    constructor(address _provider) {
        addressesProvider = ILendingPoolAddressesProvider(_provider);
    }

    fallback() external payable {}

    function transferFundsBackToPoolInternal(address _reserve, uint256 _amount)
        internal
    {
        address payable core = addressesProvider.getLendingPoolCore();
        transferInternal(core, _reserve, _amount);
    }

    function transferInternal(
        address payable _destination,
        address _reserve,
        uint256 _amount
    ) internal {
        if (_reserve == BNB_ADDRESS) {
            //solium-disable-next-line
            _destination.call{value:_amount, gas:50000}("");
            return;
        }
        IERC20(_reserve).safeTransfer(_destination, _amount);
    }

    function getBalanceInternal(address _target, address _reserve)
        internal
        view
        returns (uint256)
    {
        if (_reserve == BNB_ADDRESS) {
            return _target.balance;
        }
        return IERC20(_reserve).balanceOf(_target);
    }
}
