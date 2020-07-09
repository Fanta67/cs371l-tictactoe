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
var currentHostGame: String = ""
var currentClientGame: String = ""
var currentHostGameVC: GameVC? = nil
var currentClientGameVC: GameVC? = nil

class InviteVC: UIViewController, UITextFieldDelegate {
    
    var inviteCode: String = ""
    var playerID: String = ""
    var refHandle: DatabaseHandle = DatabaseHandle()
    @IBOutlet weak var joinRejoinLabel: UILabel!
    @IBOutlet weak var joinRejoinButton: UIButton!
    @IBOutlet weak var createRejoinLabel: UILabel!
    @IBOutlet weak var createRejoinButton: UIButton!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var inviteTextField: UITextField!
    @IBOutlet weak var createTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Allows for customized behavior for text fields.
        inviteTextField.delegate = self
        createTextField.delegate = self
        createTextField.inputView = UIView.init(frame: CGRect.zero)
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapRecognizer)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if(settings[0].value(forKeyPath: "isOn") as! Bool) {
            overrideUserInterfaceStyle = .dark
            self.navigationController?.navigationBar.barTintColor = .black
        } else {
            overrideUserInterfaceStyle = .light
            self.navigationController?.navigationBar.barTintColor = .white
        }
        inviteCode = randomString(length: 5)
        ref.child("games").observeSingleEvent(of: .value, with: { (snapshot) in
            while snapshot.hasChild(self.inviteCode) {
                self.inviteCode = self.randomString(length: 5)
            }
        })
        createTextField.text = inviteCode
        
        // Show rejoin options if currently in a game.
        if currentClientGame == "" {
            joinRejoinButton.isHidden = true
            joinRejoinLabel.isHidden = true
        } else {
            joinRejoinButton.isHidden = false
            joinRejoinLabel.isHidden = false
            joinRejoinLabel.text = "Rejoin \(currentClientGame)"
        }
        if currentHostGame == "" {
            createRejoinButton.isHidden = true
            createRejoinLabel.isHidden = true
        } else {
            createRejoinButton.isHidden = false
            createRejoinLabel.isHidden = false
            createRejoinLabel.text = "Rejoin \(currentHostGame)"
        }
    }
    
    //take segue to game and set up database with a clean game
    @IBAction func onCreateButtonPressed(_ sender: Any) {
        ref.child("games").observeSingleEvent(of: .value, with: { (snapshot) in
            if !snapshot.hasChild(self.inviteCode) {
                self.setUpGame()
            }
            currentHostGame = self.inviteCode
            self.performSegue(withIdentifier: "InviteToGameSegue", sender: nil)
        })
    }
    
    func setUpGame() {
        createTextField.text = inviteCode
        let gameRef = ref.child("games/\(inviteCode)")
        gameRef.child("player1").setValue("player1Name")
        gameRef.child("player2").removeValue()
        playerID = "player1Name"
        gameRef.child("playerTurn").setValue(1)
        
        // Set up board.
        let boardArray = [0, 0, 0, 0, 0, 0, 0, 0, 0]
        let boardDict = ["board" : boardArray]
        gameRef.updateChildValues(boardDict)
    }
    
    //check for valid game and join if the game doesnt have 2 players yet
    
    @IBAction func onJoinButtonPressed(_ sender: Any) {
        inviteTextField.resignFirstResponder()
        
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
                ref.child("games/\(self.inviteCode)/player2").setValue("player2Name")
                self.playerID = "player2Name"
                currentClientGame = self.inviteCode
                self.statusLabel.text = ""
                self.performSegue(withIdentifier: "InviteToGameSegue", sender: nil)
            } else {
                self.statusLabel.text = "Invalid invite code - game does not exist"
            }
        })
    }
    
    /// Enter into game with player id and invite code to access game via database.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let segueIdentifier = segue.identifier else { return }
        if segueIdentifier == "InviteToGameSegue" {
            let destination = segue.destination as! GameVC
            destination.inviteCode = inviteCode
            destination.playerID = self.playerID
        }
    }
    @IBAction func onJoinRejoinButtonPressed(_ sender: Any) {
        inviteCode = currentClientGame
        performSegue(withIdentifier: "InviteToGameSegue", sender: nil)
    }
    @IBAction func onCreateRejoinButtonPressed(_ sender: Any) {
        inviteCode = currentHostGame
        performSegue(withIdentifier: "InviteToGameSegue", sender: nil)
    }
    
    /// Generates a random alphanumeric String excluding l, I, 0, and O. A length of 5 produces 1 in a million chances.
    ///
    /// - Parameters:
    ///   - length: The amount of characters in the randomized String.
    func randomString(length: Int = 5) -> String {
        let letters = "abcdefghijkmnopqrstuvwxyzABCDEFGHJKLMNPQRSTUVWXYZ123456789"
        return String((0..<length).map{ _ in letters.randomElement()! })
    }

    // Functions to customize text fields.
    @objc func dismissKeyboard() {
        inviteTextField.resignFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        inviteTextField.resignFirstResponder()
        onJoinButtonPressed("")
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == createTextField {
            return false
        }
        return true
    }
}
