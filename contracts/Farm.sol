pragma solidity ^0.6.0;

import "./ERC721.sol";

contract Farm is ERC721{
    address payable private contractOwner;

    struct animal{
        string race;
        uint256 age;
        string ville;
        string color;
        string name;
        uint256 iDparent1;
        uint256 iDparent2;
        bool fight;
        uint256 fightPrice;
    }
    struct enchere{
        uint256 Idmarketplace;
        uint start;
        uint256 animalID;
        address payable currentOwner;
        address payable firstOwner;
        uint256 maxPrice;
        bool state;
    }
    event addBreeder (address breeder);
    event addAuction(uint256 IdOfAuction);
    mapping(address=>bool)public inList;
    animal[] private animalArray;
    address[] private breederArray;
    enchere[] private allRoom;
    uint256 private marketplace =1;

    constructor()public{
        contractOwner = msg.sender;
    }
    modifier ownerOfContract(){
        require(msg.sender == contractOwner,"Must be the owner of the contract");
        _;
    }
    modifier marketPlaceOpen(uint256 IDmarketplace){
        require(allRoom[IDmarketplace].firstOwner != address(0),"Marketplace should be open");
        _;
    }

    function registerBreeder(address breeder) public ownerOfContract {
        breederArray.push(breeder);
        inList[breeder] = true;
        emit addBreeder(breeder);
    }
    function AnimalInformation(uint256 animalID) public view returns(string memory race,
        uint256 age,
        string memory ville,
        string memory color,
        string memory name,
        bool fight,
        uint256 fightPrice){
        return(animalArray[animalID].race,animalArray[animalID].age,animalArray[animalID].ville,
        animalArray[animalID].color,animalArray[animalID].name,animalArray[animalID].fight,animalArray[animalID].fightPrice);
    }
    function declareAnimal(string memory race, uint256 age, string memory ville,string memory color, string memory name) public {
        animalArray.push(animal(race, age, ville, color, name,0,0,false,0));
        _mint(msg.sender, (animalArray.length-1));
    }
    function deadAnimal(uint256 tokenId) public{
        _burn(tokenId);
    }
    function breedAnimal(uint256 tokenId1, uint256 tokenID2, string memory name,string memory color) public{
        animalArray.push(animal(animalArray[tokenId1].race,0, animalArray[tokenId1].ville,color,name,tokenId1,tokenID2,false,0));
        _mint(msg.sender, (animalArray.length-1));
    }
    function createAuction(uint256 tokenId) public{
        require(ownerOf(tokenId)==msg.sender, "must be the owner of the animal");
        allRoom.push(enchere(marketplace, (block.timestamp), tokenId, msg.sender, msg.sender,0, true));
        marketplace = marketplace+1;
        emit addAuction(allRoom.length-1);
    }
    function information_marketplace(uint256 marketplaceID) public view returns(uint256 maxprice, address currentWinner, bool state){
        return(allRoom[marketplaceID].maxPrice, allRoom[marketplaceID].currentOwner,allRoom[marketplaceID].state );
    }
    function BidOnAuction(uint256 marketplaceID) public payable marketPlaceOpen(marketplaceID){
        if(now > allRoom[marketplaceID].start + 2 days){
            allRoom[marketplaceID].state = false;
        }
        require(allRoom[marketplaceID].state == true,"MarketPlace must be open to propose new price");
        if(allRoom[marketplaceID].maxPrice < msg.value){
            allRoom[marketplaceID].currentOwner.transfer(allRoom[marketplaceID].maxPrice);
            allRoom[marketplaceID].maxPrice = msg.value;
            allRoom[marketplaceID].currentOwner = msg.sender;
        }else{
            msg.sender.transfer(msg.value);
        }
    }
    function claimAuction(uint256 marketplaceID) public marketPlaceOpen(marketplaceID) {
        if(now > allRoom[marketplaceID].start + 2 days){
            allRoom[marketplaceID].state = false;
        }
        require(allRoom[marketplaceID].state == false, "MarketPlace must be over");
        require(allRoom[marketplaceID].currentOwner==msg.sender,"Must be the new owner of the animal");
        transferFrom(allRoom[marketplaceID].firstOwner, allRoom[marketplaceID].currentOwner, allRoom[marketplaceID].animalID);
        allRoom[marketplaceID].firstOwner.transfer(allRoom[marketplaceID].maxPrice);
        allRoom[marketplaceID].firstOwner = address(0);
    }
    function proposeToFight(uint256 animalID)public payable {
        require(ownerOf(animalID)==msg.sender, "must be the owner of the animal");
        animalArray[animalID].fight = true;
        animalArray[animalID].fightPrice = msg.value;
    }
    function agreeToFight(uint256 myAnimalID, uint256 fighter) public payable{
        require(ownerOf(myAnimalID)==msg.sender, "must be the owner of the animal");
        require(animalArray[fighter].fight==true,"adversary must be a fighter");
        require(animalArray[fighter].fightPrice==msg.value,"adversary must put the same amount of money");
        if(animalArray[fighter].age > animalArray[myAnimalID].age){
            payable(ownerOf(fighter)).transfer(msg.value+animalArray[fighter].fightPrice);
        }else{
            msg.sender.transfer(msg.value+animalArray[fighter].fightPrice);
        }
        animalArray[fighter].fight = false;
        animalArray[myAnimalID].fight = false;
        animalArray[fighter].fightPrice = 0;
        animalArray[myAnimalID].fightPrice = 0;
    }
}
