pragma solidity ^0.4.2;

import "./Owned.sol";
import "./Token.sol";

contract MyPlubitToken is Owned, Token {
    string public constant name = "Plubit Token";
    string public constant symbol = "PBT";
    uint256 public constant decimals = 18;
    string public version = "1.0";

    uint256 public sellPrice;
    //contracts
    //address public PlubSaleDeposit        = 0xD7199729a878c2D228cc4E82A7ce6351bEDADD2e;      // deposit address for PBT Sale contract
    //address public PlubPresaleDeposit     = 0xcc9e49b6caf08aef7ae5d6cbd012381ded693808;      // deposit address for PBT Presale Contributors
    address public PlubTeamDeposit        = 0x46a2a8C123c4584A3D05f4de84B3B4732510BC07;      // deposit address for PBT Vesting for team and advisors
    address public PlubNetDeposit        = 0x32Fd75Ac2dFC185895396155A03ea16203783cd3;      // deposit address for PBT Vesting for team and advisors



   // uint256 public constant PlubSale      = 10000000 * 10**decimals;

    //uint256 public constant MaxPlubPreSale   = 5000000 * 10**decimals; // maximum amount of tokens to be sold in pre ico
   // uint256 public PlubPreSale = 0; // amount of tokens selled in pre ico

    uint256 public constant PlubTeam      = 2000000 * 10**decimals;
    uint256 public constant PlubNet       = 10000000 * 10**decimals;

    bool public preico_setted = false;
    bool public ico_setted = false;
  //  mapping (address => bool) public frozenAccount;


  /* Initializes contract with initial supply tokens to the creator of the contract */
  function MyPlubitToken() {
  
      bytes memory data;
      Transfer(0x0,PlubTeamDeposit,PlubTeam, data);
      Transfer(0x0,PlubNetDeposit,PlubNet, data);
  }

  function load(address _ico) onlyOwner {
      require(ico_setted == false);
      Ico_contract = _ico;
      ico_setted = true;
  }

  function loadPreIco(address _preIco) onlyOwner {
      require(preico_setted == false);
      PreIco_contract = _preIco;
      preico_setted = true;
  }

  function transferFromICO(address _to, uint _value) only_ICO onlyPayloadSize(3 * 32) returns (bool success) {
    balances[_to] = safeAdd(balances[_to], _value);
    bytes memory data;
    Transfer(0, _to, _value, data);
    return true;
  }

  function transferFromPreICO(address _to, uint _value) only_PREICO onlyPayloadSize(3 * 32) returns (bool success) {
    balances[_to] = safeAdd(balances[_to], _value);
    //PlubPreSale = safeAdd(PlubPreSale, _value);
    bytes memory data;
    Transfer(0, _to, _value, data);
    return true;
  }

  modifier only_ICO
    {
        require(msg.sender == Ico_contract);
        _;
}

modifier only_PREICO
    {
        require(msg.sender == PreIco_contract);
        _;
}
/*
lock tokens until a determined date
rigth now areblocked forever
*/
modifier unlocked
    {

      require(true == false);
      _;
}

}
