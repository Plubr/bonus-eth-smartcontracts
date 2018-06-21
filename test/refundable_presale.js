
const BigNumber = web3.BigNumber;
require('chai')
  .use(require('chai-as-promised'))
  .use(require('chai-bignumber')(BigNumber))
.should();


function advanceToBlock(number) {
  if (web3.eth.blockNumber > number) {
    throw Error(`block number ${number} is in thfe past (current is ${web3.eth.blockNumber})`)
  }

  while (web3.eth.blockNumber < number) {
    web3.eth.sendTransaction({value: 1, from: web3.eth.accounts[8], to: web3.eth.accounts[7]});
  }
}

const assertJump = function(error) {
  assert.isAbove(error.message.search('VM Exception while processing transaction: revert'), -1, 'Invalid opcode error must be returned');
};


const startBlock = 3000;
const endBlock = 4000;
const minContribution = 500000000000000000;
const maxSupply = 3e+18;
const tokenExchangeRate = 1000;
const goal = 2e+18;


const RefundablePresale = artifacts.require('RefundablePresale.sol')
const MyPlubitToken = artifacts.require('MyPlubitToken.sol')
const WL = artifacts.require('WhiteList.sol')
//const Vault = artifacts.require('RefundVault.sol')

contract('RefundablePresale', function (accounts) {
    let fundRaise
    let owner = accounts[0]
    beforeEach('setup contract for each test', async function () {
        this.token  = await MyPlubitToken.new();
        fundRaise = await RefundablePresale.new(2e+18, accounts[9],
        this.token.address)
        this.wl = await WL.new();
    })
    
    it('has an owner', async function () {
        
        assert.equal(await fundRaise.owner(), owner)
    })

    it('has goal', async function () {
        let go = await fundRaise.maxSupply.call()
                
        assert.equal(go, maxSupply);
    })

    it('cant participate before time schechuled', async function () {
        try{
            await fundRaise.setWhiteList(this.wl.address);
            await this.token.loadPreIco(fundRaise.address);
            await fundRaise.sendTransaction({ value: 2e+18, from: accounts[4] })
        }
        catch(error){
            console.log('error');

            return assertJump(error);
        }
        assert.fail('should have thrown before');
    })
    it('permits send after started', async function () {
       // advanceToBlock(3000);
        await this.wl.addInvestorToWhiteList(accounts[4]);
        await fundRaise.setWhiteList(this.wl.address);
        await this.token.loadPreIco(fundRaise.address);
        await fundRaise.sendTransaction({ value: 1e+18, from: accounts[4] })
    })

    it('permits send from whitelisted addr', async function () {
        await this.wl.addInvestorToWhiteList(accounts[4]);
        await fundRaise.setWhiteList(this.wl.address);
        assert.equal(this.wl.address, await fundRaise.investorWhiteList());
        await this.token.loadPreIco(fundRaise.address);
        await fundRaise.sendTransaction({ value: 1e+18, from: accounts[4] })
    })
    it('non whitelisted addr cant participate', async function () {
        try{
            await fundRaise.setWhiteList(this.wl.address);
            await this.token.loadPreIco(fundRaise.address);
            await fundRaise.sendTransaction({ value: 2e+18, from: accounts[4] })
        }
        catch(error){
            console.log('error');

            return assertJump(error);
        }
        assert.fail('should have thrown before');
    })

    it('should not create tokens from any, just pre-ico', async function () {
        
        
        try {
            await this.wl.addInvestorToWhiteList(accounts[4]);
            await fundRaise.setWhiteList(this.wl.address);
            await fundRaise.sendTransaction({ value: 2e+18, from: accounts[4] })
        } catch (error) {
            console.log('error');
            return assertJump(error);
        }
        assert.fail('should have thrown before');
    })
    it('fail amount of ether lower than min minContribution ', async function () {
        try{
            await this.wl.addInvestorToWhiteList(accounts[4]);
            await fundRaise.setWhiteList(this.wl.address);
            assert.equal(this.wl.address, await fundRaise.investorWhiteList());
            await this.token.loadPreIco(fundRaise.address);
            await fundRaise.sendTransaction({ value: 1e+17, from: accounts[4] })
        }
        catch(error){
            console.log('error');
            return assertJump(error);
        }
            assert.fail('should have thrown before');


    })
    it('calculate tokens plus bonuses', async function () {
        await this.wl.addInvestorToWhiteList(accounts[4]);
        await fundRaise.setWhiteList(this.wl.address);
        assert.equal(this.wl.address, await fundRaise.investorWhiteList());
        await this.token.loadPreIco(fundRaise.address);
        await fundRaise.sendTransaction({ value: 1e+18, from: accounts[4] })
        let tokens ;//= New BigNumber();
        tokens = 1e+18*tokenExchangeRate+(1e+18)*1000/4;
        assert.equal(tokens, await this.token.balanceOf.call(accounts[4]));
    })
    it('pause presale and unable to send ehters-unpause send ethers', async function () {
        try{
            await this.wl.addInvestorToWhiteList(accounts[4]);
            await fundRaise.setWhiteList(this.wl.address);
            assert.equal(this.wl.address, await fundRaise.investorWhiteList());
            await this.token.loadPreIco(fundRaise.address);
            await fundRaise.pause();
            await fundRaise.sendTransaction({ value: 1e+17, from: accounts[4] })
        }
        catch(error){
            console.log('error');
            return assertJump(error);
        }
        
        assert.fail('should have thrown before');

        await fundRaise.unpause();
        await fundRaise.sendTransaction({ value: 5e+17, from: accounts[4] })
    })
    it('cant send after reach hard cap', async function () {
        
            await this.wl.addInvestorToWhiteList(accounts[4]);
            await fundRaise.setWhiteList(this.wl.address);
            assert.equal(this.wl.address, await fundRaise.investorWhiteList());
            await this.token.loadPreIco(fundRaise.address);
            await fundRaise.sendTransaction({ value: 3e+18, from: accounts[4] })
        try{
            await fundRaise.sendTransaction({ value: 1e+18, from: accounts[4] })

        }
        catch(error){
            console.log('error');
            return assertJump(error);
        }
        
        assert.fail('should have thrown before');

       
    })
    it('finalize and forward funds to wallet', async function () {
        await this.wl.addInvestorToWhiteList(accounts[4]);
        await fundRaise.setWhiteList(this.wl.address);
        await this.token.loadPreIco(fundRaise.address);
               
        await fundRaise.sendTransaction({ value: 2e+18, from: accounts[4] })
        //if(web3.eth.blockNumber < endBlock)
           // advanceToBlock(101);
        let pre = web3.eth.getBalance(accounts[9]);
        await fundRaise.finalize({from: accounts[0]});
        
        console.log(await fundRaise.weiRaised.call());
        
        let post = web3.eth.getBalance(accounts[9]);
        post.minus(pre).should.be.bignumber.equal(goal);
        
    })
    it('finalize and enable refund funds', async function () {
        
        await this.wl.addInvestorToWhiteList(accounts[4]);
        await fundRaise.setWhiteList(this.wl.address);
        await this.token.loadPreIco(fundRaise.address);
        let amount = 1e+18;
        await fundRaise.sendTransaction({ value: amount, from: accounts[4] })
        //if(web3.eth.blockNumber < endBlock)
           // advanceToBlock(101);
        let pre = web3.eth.getBalance(accounts[4]);
        await fundRaise.finalize({from: accounts[0]});

        await fundRaise.claimRefund({from: accounts[4], gasPrice: 0});
        
        let post = web3.eth.getBalance(accounts[4]);
        post.minus(pre).should.be.bignumber.equal(amount);

    })
    it('refund amount greater than hard cap', async function () {
        
        await this.wl.addInvestorToWhiteList(accounts[4]);
        await fundRaise.setWhiteList(this.wl.address);
        await this.token.loadPreIco(fundRaise.address);
               
        let pre = web3.eth.getBalance(accounts[4]);
        await fundRaise.sendTransaction({ value: 1e+18, from: accounts[4], gasPrice: 0})
        await fundRaise.sendTransaction({ value: 2e+18, from: accounts[4], gasPrice: 0})
        let post = web3.eth.getBalance(accounts[4]);

        //hard cap is set to 3, sends 4eth and 1 is refunded
        pre.minus(post).should.be.bignumber.equal(2e+18);

    })


})
