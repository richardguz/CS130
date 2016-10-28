      //
     //  Bet.swift
    //  BoredBets
   //
  //  Created by Markus Notti on 10/23/16.
 //  Copyright © 2016 SauceKitchen. All rights reserved.
//

import Foundation
import Firebase

      
//README: Here's a summary of how I'm implementing this: Bet is the superclass that the three bet types inherit from.
      //All bets have common characteristics, like comments and people betting on them, but they operate differently
      //in how they calculate odds and such.
      //calculateOdds() is overriden in all derived classes
      //TO MAKE A WAGER: wagers are attached to the bet and are created using attachWager()
      //Must give the user, amount to bet, and what the actual bet is
      //The Bet class keeps track of all the wagers. These are then used for finding odds


// need to figure out how to refactor to make this fit a design pattern
      //bets can be contructed passing in a bet id, bet title, bet description, and bet type
      //description is optional
      

      //maybe template method?
      
      class Bet {
        let betsRef = FIRDatabase.database().reference().child("Bets")
        let idLen : Int = 16
        var currentUserId : String!
        
        var id: String!
        var title: String!
        var description: String = ""
        var wagerArray: [Wager] = []

        init(){
            //for default init in createBet VC
            self.currentUserId = User.currentUser()
        }
        
        //no description
        init(title: String) {
            self.title = title
            self.currentUserId = User.currentUser()
        }
        
        // description
        init(title: String, description: String) {
            self.title = title
            self.description = description
            self.currentUserId = User.currentUser()
        }
        
        //with id (for when we pull from the database and want to store one particular bet as a bet object...
        init(id: String, title: String, description: String) {
            self.id = id
            self.title = title
            self.description = description
            self.currentUserId = User.currentUser()
        }
       
        //should always be overridden
        func calculateOdds() -> String{
            preconditionFailure()
        }
        
        //should be the same for every bet type
        func attachComment() -> Void{
            
        }
        
        //make wager and attach to the bet
        func attachWager(userId: String, betAmount: Int, userBet: Int) -> Void{
            let newWager = Wager(userId: userId, betAmount: betAmount, userBet: userBet)
            wagerArray.append(newWager)
<<<<<<< HEAD
=======
            //now update the db with the new wager object
            self.saveNewWager(newWager: newWager)
            
>>>>>>> master
        }
        
        func saveNewWager(newWager: Wager){
            let wagerData: [String: String] = [
                "user_id" : newWager.userId,
                "bet_id" : self.id,
                "bet_amount" : String(newWager.betAmount),
                "user_bet" : String(newWager.userBet)
            ]
            
            let userWagerData: [String: String] = [
                "wager_id" : newWager.id
            ]
            
            let betWagerData: [String: String] = [
                "wager_id" : newWager.id
            ]
            newWager.wagersRef.child(newWager.id).setValue(wagerData)
            User.usersRef().child(newWager.userId).child("Wagers").child(newWager.id).setValue(userWagerData)
            self.betsRef.child(self.id).child("Wagers").child(newWager.id).setValue(betWagerData)
            
            
        }
        
        func saveNewBetToFB() -> Void {
            let betId = BBUtilities.generateObjectId(len: idLen)
            //set bet ID for bet object
            self.id = betId
            let betData : [String: String] = [
                  "title" : self.title,
                  "mediator_id" : self.currentUserId,
                  "pot" : "0"
            ]
            
            let userBetData : [String : String] = [
                "bet_id" : betId
            ]
          //save bet in bets object
          self.betsRef.child(betId).setValue(betData)
            //save bet id in user object so user has reference to it
          User.usersRef().child(self.currentUserId).child("BetsMediating").child(betId).setValue(userBetData)
            
        }
      }

      //the bet where something will or will not happen
      class YesNoBet: Bet {
        override func calculateOdds() -> String{
            var numberOfYes: Int = 0
            var numberOfNo: Int = 0
            
            for wager in wagerArray {
                if wager.getUserBet() == 0 {
                    numberOfNo += 1
                }
                else if wager.getUserBet() == 1 {
                    numberOfYes += 1
                }
                else {
                    preconditionFailure("YesNo bet failure : input was not 0 or 1")
                }
            }
            
            //TODO: use numberOfNo and numberOfYes to actually calc the odds
            
            return " "
        }
      }
      
      //the bet where something must happen a certain number of times
      class ExactNumericalBet: Bet {
        override func calculateOdds() -> String{
            return " "
        }
      }
      
      //the bet where something could happen a certain number of times but if you're close you still win
      class RangedBet: Bet {
        override func calculateOdds() -> String{
            return " "
        }
      }
      
      
