// SPDX-License-Identifier: MIT
pragma solidity >=0.6.6;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./lib/SafeMathInt.sol";

contract Disbursement is Ownable {
    using SafeMath for uint256;
    using SafeMathInt for int256;

    IERC20 public debase = IERC20(0x9248c485b0B80f76DA451f167A8db30F33C70907);
    address public policy = 0x989Edd2e87B1706AB25b2E8d9D9480DE3Cc383eD;

    uint256 internal constant MAX_SUPPLY = ~uint128(0); // (2^128) - 1

    address public claimant;
    uint256 public claimAmount;
    uint256 public claimPercentage;

    function setClaimAmount(uint256 claimAmount_) external onlyOwner {
        claimAmount = claimAmount_;
    }

    function setClaimant(address claimant_) external onlyOwner {
        claimant = claimant_;
    }

    function checkStabilizerAndGetReward(
        int256 supplyDelta_,
        int256 rebaseLag_,
        uint256 exchangeRate_,
        uint256 debasePolicyBalance
    ) external returns (uint256 rewardAmount_) {
        require(
            msg.sender == policy,
            "Only debase policy contract can call this"
        );

        if (claimAmount != 0) {
            uint256 supply = debase.totalSupply();
            if (supplyDelta_ < 0) {
                supply = supply.sub(uint256(supplyDelta_.abs()));
            } else if (supplyDelta_ > 0) {
                supply = supply.add(uint256(supplyDelta_));
            }

            if (supply > MAX_SUPPLY) {
                supply = MAX_SUPPLY;
            }

            uint256 claimShare = claimAmount.mul(10**18).div(supply);
            uint256 rewardToClaim =
                debase.totalSupply().mul(claimShare).div(10**18);

            claimAmount = 0;
            if (rewardToClaim <= debasePolicyBalance) {
                return rewardToClaim;
            }
        }

        return 0;
    }

    function claimantClaimReward() external {
        require(msg.sender == claimant, "Only claimant can claim");
        debase.transfer(claimant, debase.balanceOf(address(this)));
    }
}
