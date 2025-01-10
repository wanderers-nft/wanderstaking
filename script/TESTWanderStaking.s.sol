// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {WanderStaking} from "../src/WanderStaking.sol";
import {TestToken} from "../src/TestToken.sol";
import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

contract TESTWanderStaking is Script {
    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        TestToken token = new TestToken();

        WanderStaking stakingImpl = new WanderStaking();

        bytes memory data = abi.encodeWithSignature("initialize(address,address)", address(this), address(token));
        ERC1967Proxy proxy = new ERC1967Proxy(address(stakingImpl), data);

        vm.stopBroadcast();
    }
}
