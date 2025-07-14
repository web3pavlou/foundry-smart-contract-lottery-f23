//SPDX-License-Identifier:MIT

pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {Raffle} from "src/Raffle.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
import {CreateSubscription, FundSubscription, AddConsumer} from "./Interactions.s.sol";

contract DeployRaffle is Script {
    function run() external returns (Raffle, HelperConfig) {
        HelperConfig helperConfig = new HelperConfig();
        AddConsumer addConsumer = new AddConsumer();
        HelperConfig.NetworkConfig memory config = helperConfig.getConfig();

        if (config.subscriptionId == 0) {
            //create subscription
            CreateSubscription createSubscription = new CreateSubscription();
            (
                config.subscriptionId,
                config.vrfCoordinatorV2_5
            ) = createSubscription.createSubscription(
                config.vrfCoordinatorV2_5,
                config.account
            );

            // Fund subscription
            FundSubscription fundSubscription = new FundSubscription();

            fundSubscription.fundSubscription(
                config.vrfCoordinatorV2_5,
                config.subscriptionId,
                config.link,
                config.account
            );

            helperConfig.setConfig(block.chainid, config);
        }

        vm.startBroadcast(config.account);
        Raffle raffle = new Raffle(
            config.raffleEntranceFee,
            config.automationUpdateInterval,
            config.vrfCoordinatorV2_5,
            config.gasLane,
            config.subscriptionId,
            config.callbackGasLimit
        );
        vm.stopBroadcast();

        addConsumer.addConsumer(
            address(raffle),
            config.vrfCoordinatorV2_5,
            config.subscriptionId,
            config.account
        );

        return (raffle, helperConfig);
    }
}
