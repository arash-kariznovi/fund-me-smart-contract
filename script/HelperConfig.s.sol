//SPDX-License-Identifier:MIT
// 1. deploy mockup (mock pricefeeds) when we are on a local anvil chain
// 2. keep track of contract address across different chains
    // Sepolia ETH/USD
    // Mainnet ETH/USD

pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";

contract HelperConfig is Script{

    NetworkConfig public activeNetworkConfig;
    uint8 public constant DECIMALS = 8;
    int256 public constant INITIAL_PRICE = 2000e8;

    struct NetworkConfig {
        address priceFeed; 
    }

    constructor(){
        if(block.chainid==11155111){
            activeNetworkConfig = getSepolaEthConfig();
        }else if(block.chainid==1){
            activeNetworkConfig = getMainnetEthConfig();
        }
        else{
            activeNetworkConfig = getOrCreateAnvilEthConfig();
        }
    }


    function getSepolaEthConfig() pure public returns(NetworkConfig memory){
        NetworkConfig memory sepoliaConfig = NetworkConfig({priceFeed:0x694AA1769357215DE4FAC081bf1f309aDC325306});
        return sepoliaConfig;
    }

      function getMainnetEthConfig() pure public returns(NetworkConfig memory){
        // change the address to Mainnet Eth/USD price feed
        NetworkConfig memory mainnetConfig = NetworkConfig({priceFeed:0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419});
        return mainnetConfig;
    }
    
    function getOrCreateAnvilEthConfig() public returns(NetworkConfig memory){
        // check if it is already setup!
        if(activeNetworkConfig.priceFeed != address(0)){
            return activeNetworkConfig;
        }

        vm.startBroadcast();
        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(DECIMALS, INITIAL_PRICE);
        vm.stopBroadcast();
        NetworkConfig memory anvilConfig = NetworkConfig({priceFeed:address(mockPriceFeed)});
        return anvilConfig;
        
    }
}