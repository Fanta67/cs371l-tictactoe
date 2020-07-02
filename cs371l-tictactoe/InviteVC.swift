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
    @IBAction func onGenerateButtonPressed(_ sender: Any) {
        //inviteCode = randomString(length: 5)
        inviteCode = "test1"
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
        gameRef.child("player1").setValue("playa1")//Auth.auth().currentUser().uid
        playerID = "playa1"
        gameRef.child("playerTurn").setValue(Int.random(in: 1 ... 2))
        
        /*let refHandle = gameRef.observe(DataEventType.value, with: { (snapshot) in
            let postDict = snapshot.value as? [String : AnyObject] ?? [:]
            print(postDict)
        })
 */
        
        performSegue(withIdentifier: "InviteToGameSegue", sender: nil)
        //gameRef.removeAllObservers()
        
    }
    
    @IBAction func onJoinGameButtonPressed(_ sender: Any) {
        inviteCode = inviteTextField.text!
        // Read database for valid game.
        ref.child("games").observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.hasChild(self.inviteCode) {
                ref.child("games/\(self.inviteCode)/player2").setValue("playa2")//Auth.auth().currentUser().uid
                self.playerID = "playa2"
                self.performSegue(withIdentifier: "InviteToGameSegue", sender: nil)
            } else {
                self.statusLabel.text = "Invalid invite code entered"
            }
        })
    }
    
    
    
    /// Generates a random alphanumeric String. A length of 5 produces a 1 in a million chances.
    ///
    /// - Parameters:
    ///   - length: The amount of characters in the randomized String.
    func randomString(length: Int = 5) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length).map{ _ in letters.randomElement()! })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    /*
    override func viewWillAppear(_ animated: Bool) {
        if(settings[0].value(forKeyPath: "isOn") as! Bool) {
            overrideUserInterfaceStyle = .dark
        } else {
            overrideUserInterfaceStyle = .light
        }
    }
    */
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let segueIdentifier = segue.identifier else { return }
        if segueIdentifier == "InviteToGameSegue" {
            (segue.destination as! GameVC).inviteCode = inviteCode
        }
    }
    
}
