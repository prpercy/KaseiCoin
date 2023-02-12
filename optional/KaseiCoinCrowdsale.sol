pragma solidity ^0.5.5;

import "./KaseiCoin.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/crowdsale/Crowdsale.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/crowdsale/emission/MintedCrowdsale.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/crowdsale/validation/CappedCrowdsale.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/crowdsale/validation/TimedCrowdsale.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/crowdsale/distribution/RefundablePostDeliveryCrowdsale.sol";


// The KaseiCoinCrowdsale contract inherit the following OpenZeppelin:
// * Crowdsale
// * MintedCrowdsale
contract KaseiCoinCrowdsale is Crowdsale, MintedCrowdsale, CappedCrowdsale, TimedCrowdsale, RefundablePostDeliveryCrowdsale { // UPDATE THE CONTRACT SIGNATURE TO ADD INHERITANCE
    
    // Provide parameters for all of the features of your crowdsale, such as the `rate`, `wallet` for fundraising, and `token`.
    constructor(
        uint rate,
        address payable wallet, // sale beneficiary
        KaseiCoin token, // the KaseiCoin, the Crowdsale will work with
        uint goal, //amount of ether which you hope to raise during the crowdsale
        uint open, //represents the opening time for the crowdsale
        uint close //represents the closing time for the crowdsale.
    ) public 
        Crowdsale(rate, wallet, token) 
        CappedCrowdsale(goal)
        TimedCrowdsale(open, close)
        RefundableCrowdsale(goal)
    {
    // constructor can stay empty
    }
}

// A temporary helper contract that will help us set up, configure, and deploy our KaseiCoin and KaseiCoinCrowdsale contracts
// After deployment and the initial setup of our crowdsale, KaseiCoinCrowdsaleDeployer will turn over control of the crowdsale to KaseiCoinCrowdsale.
contract KaseiCoinCrowdsaleDeployer {
    // Create an `address public` variable called `kasei_token_address`.
    address public kasei_token_address;
    // Create an `address public` variable called `kasei_crowdsale_address`.
    address public kasei_crowdsale_address;

    // Add the constructor.
    constructor(
        string memory name, // KaseiCoin
        string memory symbol, // KAI
        address payable wallet, // this address will receive all Ether raised by the sale
        uint goal // crowdsale goal
    ) public {
        // Create a new instance of the KaseiCoin contract.
        KaseiCoin kasei_coin = new KaseiCoin(name, symbol, 0);
        
        // Assign the token contract’s address to the `kasei_token_address` variable.
        kasei_token_address = address(kasei_coin);

        // Create a new instance of the `KaseiCoinCrowdsale` contract
        // rate =1 to maintain parity with Ether
        // wallet - pass on from constructor. This wallet will recieve proceeds of sale
        KaseiCoinCrowdsale kasei_coin_crowdsale = new KaseiCoinCrowdsale(1,wallet,kasei_coin, goal, now, now + 24 weeks);
            
        // Aassign the `KaseiCoinCrowdsale` contract’s address to the `kasei_crowdsale_address` variable.
        kasei_crowdsale_address = address(kasei_coin_crowdsale);

        // Set the `KaseiCoinCrowdsale` contract as a minter
        kasei_coin.addMinter(kasei_crowdsale_address);
        
        // Have the `KaseiCoinCrowdsaleDeployer` renounce its minter role.
        kasei_coin.renounceMinter();
    }
}
