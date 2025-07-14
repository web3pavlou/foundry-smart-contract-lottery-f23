// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Test} from "forge-std/Test.sol";
import {console} from "forge-std/console.sol";
import {HelperConfig, CodeConstants} from "../../script/HelperConfig.s.sol";
import {CreateSubscription, FundSubscription, AddConsumer} from "../../script/Interactions.s.sol";
import {VRFCoordinatorV2_5Mock} from "@chainlink/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol";
import {LinkToken} from "../Mocks/LinkToken.sol";
import {Raffle} from "../../src/Raffle.sol";

contract InteractionsTest is Test {
    CreateSubscription createSubscription;

    /*//////////////////////////////////////////////////////////////
                                STATE VARIABLES
    //////////////////////////////////////////////////////////////*/
    uint256 subscriptionId;
    bytes32 gasLane;
    uint256 automationUpdateInterval;
    uint256 raffleEntranceFee;
    uint32 callbackGasLimit;
    address vrfCoordinatorV2_5;
    LinkToken link;

    uint96 public constant MOCK_BASE_FEE = 0.25 ether;
    uint96 public constant MOCK_GAS_PRICE_LINK = 1e9;
    int256 public constant MOCK_WEI_PER_UINT_LINK = 4e15;

    /*//////////////////////////////////////////////////////////////
                                FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    function setUp() external {
        createSubscription = new CreateSubscription();
        createSubscription.run();
    }

    function testCreateSubscriptionDirectCall() public {
        address account = address(1);
        VRFCoordinatorV2_5Mock vrfCoordinator = new VRFCoordinatorV2_5Mock(
            MOCK_BASE_FEE,
            MOCK_GAS_PRICE_LINK,
            MOCK_WEI_PER_UINT_LINK
        );

        (uint256 subId, address vrfCoordinatorAddress) = (
            new CreateSubscription()
        ).createSubscription(address(vrfCoordinator), account);

        assertGt(subId, 0, "Subscription ID should not be zero");
        assertEq(
            vrfCoordinatorAddress,
            address(vrfCoordinator),
            "Coordinator address should match"
        );
    }

    function testCreateSubscriptionUsingConfig() public {
        CreateSubscription createSub = new CreateSubscription();
        (uint256 subId, address vrfCoordinatorAddress) = createSub
            .createSubscriptionUsingConfig();

        assertGt(subId, 0, "SubId should not be zero (using config)");
        assertTrue(
            vrfCoordinatorAddress != address(0),
            "Coordinator address should not be zero"
        );
    }

    function testCreateSubscriptionWithRun() public {
        CreateSubscription createSub = new CreateSubscription();
        (uint256 subId, address vrfCoordinatorAddress) = createSub.run();
        assertGt(subId, 0, "run() should produce nonzero subId");
        assertTrue(
            vrfCoordinatorAddress != address(0),
            "run() should produce valid coordinator address"
        );
    }

    function testAddConsumer() public {
        VRFCoordinatorV2_5Mock vrfCoordinator = new VRFCoordinatorV2_5Mock(
            MOCK_BASE_FEE,
            MOCK_GAS_PRICE_LINK,
            MOCK_WEI_PER_UINT_LINK
        );

        uint256 subId = vrfCoordinator.createSubscription();
        address consumer = address(0x1234);
        address owner = address(this);
        vm.deal(owner, 10 ether);

        AddConsumer addConsumerScript = new AddConsumer();
        addConsumerScript.addConsumer(
            consumer,
            address(vrfCoordinator),
            subId,
            owner
        );
    }

    function testFundSubscriptionDirectCall() public {
        VRFCoordinatorV2_5Mock vrfCoordinator = new VRFCoordinatorV2_5Mock(
            MOCK_BASE_FEE,
            MOCK_GAS_PRICE_LINK,
            MOCK_WEI_PER_UINT_LINK
        );
        LinkToken linkToken = new LinkToken();
        address owner = address(this);
        vm.deal(owner, 10 ether);

        vm.prank(owner);
        uint256 subId = vrfCoordinator.createSubscription();

        FundSubscription fundSubscriptionInstance = new FundSubscription();

        (uint96 balanceBefore, , , , ) = vrfCoordinator.getSubscription(subId);
        assertEq(balanceBefore, 0, "Balance should be zero before funding");

        fundSubscriptionInstance.fundSubscription(
            address(vrfCoordinator),
            subId,
            address(linkToken),
            owner
        );

        (uint96 balanceAfter, , , , ) = vrfCoordinator.getSubscription(subId);
        assertEq(
            balanceAfter,
            fundSubscriptionInstance.FUND_AMOUNT(),
            "Balance should equal FUND_AMOUNT after funding"
        );

        assertGt(subId, 0, "SubId should not be zero");
        assertTrue(
            address(vrfCoordinator) != address(0),
            "Coordinator address should not be zero"
        );
    }

    function testFundSubscriptionUsingConfig() public {
        VRFCoordinatorV2_5Mock vrfCoordinator = new VRFCoordinatorV2_5Mock(
            MOCK_BASE_FEE,
            MOCK_GAS_PRICE_LINK,
            MOCK_WEI_PER_UINT_LINK
        );
        LinkToken linkToken = new LinkToken();
        address owner = address(this);
        vm.deal(owner, 10 ether);

        vm.prank(owner);
        uint256 subId = vrfCoordinator.createSubscription();

        HelperConfig helperConfig = new HelperConfig();
        HelperConfig.NetworkConfig memory net = helperConfig.getConfig();
        net.vrfCoordinatorV2_5 = address(vrfCoordinator);
        net.link = address(linkToken);
        net.subscriptionId = subId;
        net.account = owner;
        helperConfig.setConfig(helperConfig.LOCAL_CHAIN_ID(), net);

        FundSubscription fundSubscriptionInstance = new FundSubscription();
        fundSubscriptionInstance.fundSubscriptionUsingConfig();
    }
}
