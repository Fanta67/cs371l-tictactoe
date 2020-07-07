//
//  InviteVC.swift
//  cs371l-tictactoe
//  EID: bv5433, dk9362
//  Course: CS371L
//
//  Created by Dylan Kan on 6/21/20.
//  Copyright © 2020 billyvo. All rights reserved.
//

import UIKit
import Firebase

var ref: DatabaseReference = Database.database().reference()

class InviteVC: UIViewController {
    
    var inviteCode = ""
    var playerID = ""
    var refHandle: DatabaseHandle = DatabaseHandle()
    @IBOutlet weak var statusLabel: UILabel!
    
    @IBOutlet weak var inviteTextField: UITextField!
    @IBOutlet weak var inviteLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if(settings[0].value(forKeyPath: "isOn") as! Bool) {
            overrideUserInterfaceStyle = .dark
            self.navigationController?.navigationBar.barTintColor = .black
        } else {
            overrideUserInterfaceStyle = .light
            self.navigationController?.navigationBar.barTintColor = .white
        }
    }
    
    @IBAction func onGenerateButtonPressed(_ sender: Any) {
        //inviteCode = randomString(length: 5)
        inviteCode = "game0"
        /*
        let single = ref.child("games").observeSingleEvent(of: .value, with: { (snapshot) in
            while snapshot.hasChild(self.inviteCode) {
                self.inviteCode = self.randomString(length: 5)
            }
        })
         */
        
        // Invite Code is valid, set up game.
        inviteLabel.text = inviteCode
        let gameRef = ref.child("games/\(inviteCode)")
        gameRef.child("player1").setValue("player1Name")
        playerID = "player1Name"
        gameRef.child("playerTurn").setValue(1)
        
        // Set up board.
        let boardArray = [0, 0, 0, 0, 0, 0, 0, 0, 0]
        let boardDict = ["board" : boardArray]
        gameRef.updateChildValues(boardDict)
        
        performSegue(withIdentifier: "InviteToGameSegue", sender: nil)
    }
    
    @IBAction func onJoinGameButtonPressed(_ sender: Any) {
        inviteCode = inviteTextField.text!
        if inviteCode.isEmpty {
            self.statusLabel.text = "Invalid invite code - please enter a code"
            return
        }
        
        // Check for invalid characters that won't work with Firebase database.
        let characterSet = CharacterSet(charactersIn: ".#$[]")
        if inviteCode.rangeOfCharacter(from: characterSet) != nil {
            self.statusLabel.text = "Invalid invite code - contains invalid character(s)"
            return
        }
        
        // Read and check database for valid game.
        ref.child("games").observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.hasChild(self.inviteCode) {
                if !snapshot.hasChild("\(self.inviteCode)/player2") {
                    ref.child("games/\(self.inviteCode)/player2").setValue("player2Name")
                    self.playerID = "player2Name"
                    self.performSegue(withIdentifier: "InviteToGameSegue", sender: nil)
                } else {
                    self.statusLabel.text = "Invalid invite code - two players already in game"
                }
            } else {
                self.statusLabel.text = "Invalid invite code - game does not exist"
            }
        })
    }
    
    /// Generates a random alphanumeric String. A length of 5 produces 1 in a million chances.
    ///
    /// - Parameters:
    ///   - length: The amount of characters in the randomized String.
    func randomString(length: Int = 5) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length).map{ _ in letters.randomElement()! })
    }
    
    //enter game with player id and invite code to access game
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let segueIdentifier = segue.identifier else { return }
        if segueIdentifier == "InviteToGameSegue" {
            (segue.destination as! GameVC).inviteCode = inviteCode
            (segue.destination as! GameVC).playerID = self.playerID
        }
    }
    
}
