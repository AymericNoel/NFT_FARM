const Farm = artifacts.require("Farm.sol");



var accounts= web3.eth.getAccounts()


contract("Farm",async (accounts)=>{
    it("Should put my address in the list",async ()=>
    {
        let instance= await Farm.deployed();
        instance.registerBreeder("0x55eE1D15fE87fe0a031A8F2f4d001F339f3dF58A") ;
        let found = await instance.inList("0x55eE1D15fE87fe0a031A8F2f4d001F339f3dF58A");
        assert.equal(true, found);     
    });
    it("Should create an animal and i should be the owner",async()=>{
        let instance=await Farm.deployed();
        let result = await instance.declareAnimal("huskie", 2, "paris","beige clair", "Dao");
        let id =  await result.logs[0].args[2].words[0];
        let address =await instance.ownerOf(id);
        assert.equal("0x55eE1D15fE87fe0a031A8F2f4d001F339f3dF58A", address);
    });
    it("Should kill an animal = burn a token",async()=>{
        let instance=await Farm.deployed();
        let result = await instance.declareAnimal("huskie", 2, "paris","beige clair", "Dao");
        let id =  await result.logs[0].args[2].words[0];
        let kill = await instance.deadAnimal(id);
        let adress0 = await kill.logs[0].args[1];
        assert.equal("0x0000000000000000000000000000000000000000", adress0);
    });
    it("Should fight and win",async ()=>{        
        let instance=await Farm.deployed();
        let result = await instance.declareAnimal("huskie", 10, "paris","beige clair", "Dao",{from: accounts[0]});
        let id1 =  await result.logs[0].args[2].words[0];
        let result2 = await instance.declareAnimal("chat", 2, "londres","beige clair", "milkf",{from: accounts[1]});
        let id2 =  await result2.logs[0].args[2].words[0];
        instance.proposeToFight.sendTransaction(id1,{from: "0x55eE1D15fE87fe0a031A8F2f4d001F339f3dF58A",  value:  web3.utils.toWei('4', 'ether') });
        instance.agreeToFight.sendTransaction(id2,id1,{from: accounts[1],value : web3.utils.toWei('4', 'ether')});
        let balance = await web3.eth.getBalance(accounts[0]);
        let balance2 = await web3.eth.getBalance(accounts[1]);
        let diff= parseInt(balance2, 10) + parseInt(web3.utils.toWei('4', 'ether') , 10);
        assert(balance >= diff, "should be up that 4 eth" );
    })

    // it("Should buy animal in auction",async()=>{
    //     let instance=await Farm.deployed();
    //     let result = await instance.declareAnimal("huskie", 10, "paris","beige clair", "Dao",{from: accounts[0]});
    //     let id1 =  await result.logs[0].args[2].words[0];
    //     instance.createAuction(id1,{from :accounts[0]});
    //     instance.BidOnAuction.sendTransaction(0,{from: accounts[2],value : web3.utils.toWei('20', 'ether')});
    //     instance.claimAuction(0,{from: accounts[2]});
    //     let address =await instance.ownerOf(id1);
    //     assert.equal(accounts[2], address);
    // })
});
