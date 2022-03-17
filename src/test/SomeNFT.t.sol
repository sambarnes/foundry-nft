// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.13;

import {DSTestPlus} from "./utils/DSTestPlus.sol";

import {SomeNFT} from "../SomeNFT.sol";

contract SomeNFTTest is DSTestPlus {
    SomeNFT someNFT;

    function setUp() public {
        someNFT = new SomeNFT("Good Mornings", "GMS", "https://gm.io/tokens/");
    }

    function testMint() public {
        someNFT.mint{value: someNFT.price() * 5}(5);
        assertEq(someNFT.balanceOf(address(this)), 5);
        assertEq(someNFT.totalSupply(), 5);
    }

    function testSingleMint() public {
        someNFT.mint{value: someNFT.price()}(1);
        assertEq(someNFT.balanceOf(address(this)), 1);
        assertEq(someNFT.totalSupply(), 1);
    }

    function testWithdraw() public {
        someNFT.mint{value: someNFT.price()}(1);
        someNFT.withdraw();
        assertEq(address(someNFT.vaultAddress()).balance, someNFT.price());
        assertEq(address(someNFT).balance, 0);
    }

    function testMintMoreThanMax() public {
        vm.expectRevert(abi.encodeWithSignature("MaxAmountPerTxReached()"));
        someNFT.mint{value: 1.2 ether}(8);
    }

    function testMintNoEtherSent() public {
        vm.expectRevert(abi.encodeWithSignature("WrongEtherAmount()"));
        someNFT.mint(1);
    }

    function testMintNotEnoughEtherSent() public {
        vm.expectRevert(abi.encodeWithSignature("WrongEtherAmount()"));
        someNFT.mint{value: 0.1 ether}(1);
    }

    function testMintOutOfTokens() public {
        // Cheat code to mock a state variable w/o needing to actually make the txs
        vm.store(
            address(someNFT),
            bytes32(uint256(7)),
            bytes32(uint256(10000))
        );
        vm.expectRevert(abi.encodeWithSignature("MaxSupplyReached()"));
        someNFT.mint{value: 0.15 ether}(1);
    }

    function testMintPartialOrder() public {
        vm.store(address(someNFT), bytes32(uint256(7)), bytes32(uint256(9999)));
        vm.expectRevert(abi.encodeWithSignature("MaxSupplyReached()"));
        someNFT.mint{value: 0.3 ether}(2);
    }
}
