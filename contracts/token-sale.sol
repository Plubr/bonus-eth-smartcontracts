pragma solidity ^0.4.2;

import "./Owned.sol";
import "./Pausable.sol";
import "./MathLib.sol";
import "./MyPlubitToken.sol";
import "./WhiteList.sol";

contract SalePlubitContract is Owned, Pausable, MathLib {

    MyPlubitToken    pub;

    // crowdsale parameters
    uint256 public startBlock = 3000;
    uint256 public endBlock   = 400000;
    uint256 public ethHardCap = 10* 10**decimals;                                       //hard capitalization
    address public ethFundDeposit   = 0xCAb07e359322702Cc34eD480bb20aF8Aab6aD6A9;      // deposit address for ETH for plubit Fund
    
    bool public isFinalized;                                                            // switched to true in operational state
    uint256 public constant decimals = 18;                                              // #dp in token contract
    uint256 public tokenCreationCap;                                                    //tokens created on ico sale
    uint256 public constant tokenExchangeRate = 1000;                                   // define how many tokens per 1 ETH
    uint256 public constant minContribution = 0.05 ether;
    uint256 public constant MAX_GAS_PRICE = 50000000000 wei;                            // maximum gas price for contribution transactions

    // amount of raised money in wei
    uint256 public weiRaised;

    WhiteList public investorWhiteList; //whitelisted investors                          

    function SalePlubitContract(address token) {
        pub = MyPlubitToken(token);
        tokenCreationCap = 0;
        isFinalized = false;
    }

    event MintPlub(address to, uint256 val);
    event LogRefund(address indexed _to, uint256 _value);
    event CreateTokensEvent();


    function CreatePlub(address to, uint256 val) internal returns (bool success) {
        MintPlub(to,val);
        return pub.transferFromICO(to, val);
    }

    function () payable {
        CreateTokensEvent();
        createTokens(msg.sender,msg.value);
    }

    /// @dev Accepts ether and creates new IND tokens.
    function createTokens(address _beneficiary, uint256 _value) internal whenNotPaused {
      require (ethHardCap > weiRaised);                                         // CAP reached no more please
      require (block.number >= startBlock);
      require (block.number <= endBlock);
      require (_value >= minContribution);                                              // To avoid spam transactions on the network
      require (!isFinalized);
      require (tx.gasprice <= MAX_GAS_PRICE);

      uint256 tokens = safeMult(_value, tokenExchangeRate);                             // check that we're not over totals
      uint256 checkedSupply = safeAdd(weiRaised, _value);

      //require (pub.balanceOf(msg.sender) + tokens <= maxTokens);

      // fairly allocate the last few tokens
      if (ethHardCap < checkedSupply) {
        uint256 ethersToAllocate = safeSubtract(ethHardCap, weiRaised);
        uint256 ethersToRefund   = safeSubtract(_value,ethersToAllocate);
        weiRaised = ethHardCap;

        //analize if it wil have bonuses
        //tokens = safeMult(ethersToAllocate, tokenExchangeRate);
        //bonuses = calculateBonus(tokens);
        //tokens = safeAdd(tokens, bonuses);
        tokenCreationCap = safeAdd(tokenCreationCap, tokens);

        require(CreatePlub(_beneficiary,tokens));                              // Create

        LogRefund(msg.sender,ethersToRefund);
        msg.sender.transfer(ethersToRefund); 
        sendFunds();
        
        return;
      }

      weiRaised = checkedSupply;
      //if it will has bonuses
      //tokens = safeAdd(bonuses, tokens);
      tokenCreationCap = safeAdd(tokenCreationCap, tokens);

      require(CreatePlub(_beneficiary, tokens));                                         // logs token creation
      sendFunds();
    }


      //if has bonuses
     function calculateBonus(uint256 _tokens) private returns(uint256){

      return safeDiv(_tokens, 4);

    }


    function sendFunds() internal {

    }

}
