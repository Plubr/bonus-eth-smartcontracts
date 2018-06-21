pragma solidity ^0.4.2;


import "./Owned.sol";
import "./MathLib.sol";
import "./token-sale.sol";
import "./RefundVault.sol";


/**
 * @title RefundableCrowdsale
 * @dev Extension of PreSalePlubitContract contract that adds a funding goal, and
 * the possibility of users getting a refund if goal is not met.
 * Uses a RefundVault as the crowdsale's vault.
 */
contract RefundableIco is SalePlubitContract{
  //using MathLib for uint256;

  // minimum amount of funds to be raised in weis
  uint256 public goal;

  // refund vault used to hold funds while crowdsale is running
  RefundVault public vault;

  function RefundableIco(uint256 _goal, address ethVaultAddr, address token) SalePlubitContract(token) public {
    require(_goal > 0);
    vault = new RefundVault(ethVaultAddr); // addr where funds will be forwarded after ico finalized and sofcapt(goal) is reached
    goal = _goal;
  }

  // if crowdsale is unsuccessful, investors can claim refunds here
  function claimRefund() public {
    require(isFinalized);
    require(!goalReached());

    vault.refund(msg.sender);
  }

  function goalReached() public returns (bool) {

    return weiRaised >= goal;
  }

  // vault finalization task, called when owner calls finalize()
  function finalize() external onlyOwner {
    if (goalReached()) {
      vault.close();
    } else {
      vault.enableRefunds();
    }
    isFinalized = true;
   
  }


  // We're overriding the fund forwarding from Crowdsale.
  // In addition to sending the funds, we want to call
  // the RefundVault deposit function
  function sendFunds() internal {
    vault.deposit.value(msg.value)(msg.sender);
  }

}