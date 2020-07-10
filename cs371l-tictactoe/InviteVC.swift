//
//  Filename: InviteVC.swift
//  cs371l-tictactoe
//  EID: bv5433, dk9362
//  Course: CS371L
//
//  Created by Billy Vo and Dylan Kan on 6/22/20.
//  Copyright © 2020 billyvo and dylan.kan67. All rights reserved.
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
        
        // Assign a randomized code of length 5 until it is unique in the database.
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
    
    // Segue to game and set up database with a clean game.
    @IBAction func onCreateButtonPressed(_ sender: Any) {
        ref.child("games").observeSingleEvent(of: .value, with: { (snapshot) in
            if !snapshot.hasChild(self.inviteCode) {
                self.setUpGame()
            }
            currentHostGame = self.inviteCode
            self.performSegue(withIdentifier: "InviteToGameSegue", sender: nil)
        })
    }
    
    // Set's up the database's fields to begin game. Lobby creator is always player 1.
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
    
    // Check for valid game and join as player 2.
    @IBAction func onJoinButtonPressed(_ sender: Any) {
        inviteTextField.resignFirstResponder()
        
        inviteCode = inviteTextField.text!
        if inviteCode.isEmpty {
            self.statusLabel.text = "Invalid invite code - please enter a code"
            return
        }
        
        // Check for invalid characters that will cause Firebase database errors.
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
    
    // Enter into game with player id and invite code to access game via database.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let segueIdentifier = segue.identifier else { return }
        if segueIdentifier == "InviteToGameSegue" {
            let destination = segue.destination as! GameVC
            destination.inviteCode = inviteCode
            destination.playerID = self.playerID
        }
    }
    
    // Allows user to go back into the game with previous inviteCode as player 2.
    @IBAction func onJoinRejoinButtonPressed(_ sender: Any) {
        inviteCode = currentClientGame
        performSegue(withIdentifier: "InviteToGameSegue", sender: nil)
    }
    
    // Allows user to go back into the game with previous inviteCode as player 1.
    @IBAction func onCreateRejoinButtonPressed(_ sender: Any) {
        inviteCode = currentHostGame
        performSegue(withIdentifier: "InviteToGameSegue", sender: nil)
    }
    
    // Generates a random alphanumeric String of given length excluding l, I, O, and 0.
    // A random Stirng with default length of 5 produces more than 5 million possibilities.
    func randomString(length: Int = 5) -> String {
        let letters = "abcdefghijkmnopqrstuvwxyzABCDEFGHJKLMNPQRSTUVWXYZ123456789"
        return String((0..<length).map{ _ in letters.randomElement()! })
    }

    // Function to resign control of the keyboard, to be used by a selector.
    @objc func dismissKeyboard() {
        inviteTextField.resignFirstResponder()
    }
    
    // Actions to take when return key is pressed while editing text.
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        inviteTextField.resignFirstResponder()
        onJoinButtonPressed("")
        return true
    }
    
    // Prevents modification of the createTextField while allowing user to copy it.
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == createTextField {
            return false
        }
        return true
    }
}
