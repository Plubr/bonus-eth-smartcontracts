pragma solidity ^0.4.2;

import "./Owned.sol";

contract WhiteList is Owned {
  mapping (address => bool) public investorWhiteList;

  mapping (address => address) public referralList;

  function InvestorWhiteList() {

  }

  function addInvestorToWhiteList(address investor) external onlyOwner {
    require(investor != 0x0 && !investorWhiteList[investor]);
    investorWhiteList[investor] = true;
  }

  function removeInvestorFromWhiteList(address investor) external onlyOwner {
    require(investor != 0x0 && investorWhiteList[investor]);
    investorWhiteList[investor] = false;
  }

  //when new user will contribute ICO contract will automatically send bonus to referral
  function addReferralOf(address investor, address referral) external onlyOwner {
    require(investor != 0x0 && referral != 0x0 && referralList[investor] == 0x0 && investor != referral);
    referralList[investor] = referral;
  }

  function isAllowed(address investor) constant external returns (bool result) {
    return investorWhiteList[investor];
  }

  function getReferralOf(address investor) constant external returns (address result) {
    return referralList[investor];
  }
}