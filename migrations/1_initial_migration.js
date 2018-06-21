var Migrations = artifacts.require("./Migrations.sol");
var RefundablePresale = artifacts.require("./RefundablePresale.sol");
var PreSalePlubitContract= artifacts.require("./PreSalePlubitContract.sol");
var MyPlubitToken = artifacts.require("./MyPlubitToken.sol");
var MyMath = artifacts.require("./MathLib.sol");
var Pausa =  artifacts.require("./Pausable.sol");
var Vault =  artifacts.require("./RefundVault.sol");

module.exports = function(deployer) {
  /*deployer.deploy(Migrations);

  deployer.deploy(MyPlubitToken).then(function(){
    deployer.deploy(RefundablePresale,50000000000000000000,
    	MyPlubitToken.address)});
  */
};
