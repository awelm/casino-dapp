pragma solidity ^0.4.11;

contract Casino {
   address owner;
   uint public minimumBet;
   uint public totalBet;
   uint public numberOfBets;
   uint public maxAmountOfBets = 100;
   uint public minBetNumber = 1;
   uint public maxBetNumber = 10;
   address[] players;

   struct Player {
     uint amountBet;
     uint numberSelected;
   }

   mapping(address => Player) playerInfo;
   mapping(uint => uint) amountBetPerNumber;

   function Casino(uint _minimumBet){
      owner = msg.sender;
      minBetNumber = 1;
      maxBetNumber = 10;
      if(_minimumBet != 0) minimumBet = _minimumBet;
   }

   function kill(){
      if(msg.sender == owner)
         selfdestruct(owner);
   }

   // Lets a user bet on a number between 1 and 10
   function bet(uint number) payable{
     assert(checkPlayerExists(msg.sender) == false);
     assert(number>=minBetNumber && number<=maxBetNumber);
     assert(msg.value >= minimumBet);

     playerInfo[msg.sender].amountBet = msg.value;
     playerInfo[msg.sender].numberSelected = number;
     totalBet += msg.value;
     players.push(msg.sender);
     amountBetPerNumber[number] += msg.value;
     numberOfBets++;

     if(numberOfBets >= maxAmountOfBets) generateNumberWinner();
   }

   // Generates a random number between 1 and 10
   // TODO: Very primitive random number generator. Make it more secure
   function generateNumberWinner() {
     uint random_num = block.number % 10 + 1;
     distributePrizes(random_num);
   }

   function distributePrizes(uint winningNumber) {
     for(uint i = 0; i <= players.length; i++){
       address playerAddress = players[i];
       if(playerInfo[playerAddress].numberSelected == winningNumber) {
         uint amountBet = playerInfo[playerAddress].amountBet;
         uint totalBetOnWinner = amountBetPerNumber[winningNumber];
         uint winnings = (amountBet / totalBetOnWinner) * totalBet;
         playerAddress.transfer(winnings);
       }
       delete playerInfo[playerAddress];
     }
     resetData();
   }

   function resetData() {
     players.length = 0;
     // reset all bet counters to 0
     for(uint j = minBetNumber; j <= maxBetNumber; j++){
       amountBetPerNumber[j] = 0;
     }
   }

   function checkPlayerExists(address player) constant returns(bool){
     for(uint i = 0; i <= players.length; i++) {
       if(players[i] == player) return true;
     }
     return false;
   }

   // Fallback function in case someone sends ether to the contract so it
   // doesn't get lost
   function() payable {}
}
