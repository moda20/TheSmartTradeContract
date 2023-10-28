pragma solidity >=0.5.0;

/**
@title ILendingPoolAddressesProvider interface
@notice provides the interface to fetch the LendingPoolCore address
 */

abstract contract ILendingPoolAddressesProvider {
    function getLendingPool() public view virtual returns (address);

    function setLendingPoolImpl(address _pool) virtual public;

    function getLendingPoolCore() public virtual view returns (address payable);

    function setLendingPoolCoreImpl(address _lendingPoolCore) public virtual;

    function getLendingPoolConfigurator() public virtual view returns (address);

    function setLendingPoolConfiguratorImpl(address _configurator) public virtual;

    function getLendingPoolDataProvider() public virtual view returns (address);

    function setLendingPoolDataProviderImpl(address _provider) public virtual;

    function getLendingPoolParametersProvider() public virtual view returns (address);

    function setLendingPoolParametersProvider(address _parametersProvider) public virtual;

    function getFeeProvider() public virtual view returns (address);

    function setFeeProviderImpl(address _feeProvider) public virtual;

    function getLendingPoolLiquidationManager() public virtual view returns (address);

    function setLendingPoolLiquidationManager(address _manager) public virtual;

    function getLendingPoolManager() public virtual view returns (address);

    function setLendingPoolManager(address _lendingPoolManager) public virtual;

    function getPriceOracle() public virtual view returns (address);

    function setPriceOracle(address _priceOracle) public virtual;

    function getLendingRateOracle() public virtual view returns (address);

    function setLendingRateOracle(address _lendingRateOracle) public virtual;

    function getRewardManager() public virtual view returns (address);

    function setRewardManager(address _manager) public virtual;

    function getLpRewardVault() public virtual view returns (address);

    function setLpRewardVault(address _address) public virtual;

    function getGovRewardVault() public virtual view returns (address);

    function setGovRewardVault(address _address) public virtual;

    function getSafetyRewardVault() public virtual view returns (address);

    function setSafetyRewardVault(address _address) public virtual;
    
    function getStakingToken() public virtual view returns (address);

    function setStakingToken(address _address) public virtual;
        
        
}
