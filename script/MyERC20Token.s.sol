// script/MyERC20Token.s.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {MyERC20Token} from "../src/MyERC20Token.sol"; 

contract DeployMyToken is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        
        vm.startBroadcast(deployerPrivateKey);

        MyERC20Token myToken = new MyERC20Token(); 

        vm.stopBroadcast();
    }
}

// forge test --fork-url $SEPOLIA_RPC_URL

// forge verify-contract 0xE0628895A4C4d254b3A231a4dc3148A3c4b63294 \
//     src/MyERC20Token.sol:MyERC20Token \
//     --chain sepolia \
//     --etherscan-api-key NS7EDZ9W3H35QEMRQIPWMZ1G86WU7DZEUB \
//     --watch

// transfer

// cast send 0xE0628895A4C4d254b3A231a4dc3148A3c4b63294 \
//     "transfer(address,uint256)" \
//     0x1234567890123456789012345678901234567890 \
//     10ether \
//     --rpc-url $SEPOLIA_RPC_URL \
//     --private-key $PRIVATE_KEY

// check balance

// cast call 0xE0628895A4C4d254b3A231a4dc3148A3c4b63294 \
//     "balanceOf(address)" 0x7C93183e806921F02317b7D8e040Ae371d803428 \
//     --rpc-url $SEPOLIA_RPC_URL