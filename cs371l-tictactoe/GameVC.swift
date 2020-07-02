//
//  GameVC.swift
//  cs371l-tictactoe
//  EID: bv5433, dk9362
//  Course: CS371L
//
//  Created by Dylan Kan on 6/21/20.
//  Copyright © 2020 billyvo. All rights reserved.
//

import UIKit
import Firebase
import Foundation

class GameVC: UIViewController {
    
    let queue = DispatchQueue(label: "q1", qos: .userInitiated)
    
    var inviteCode: String = ""
    var playerID: String = ""
    var gameRef: DatabaseReference = Database.database().reference()

    @IBOutlet weak var blButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        gameRef = Database.database().reference().child("game/\(inviteCode)")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        /*
        if(settings[0].value(forKeyPath: "isOn") as! Bool) {
            overrideUserInterfaceStyle = .dark
        } else {
            overrideUserInterfaceStyle = .light
        }
         */
    }
    
    func game() {
        let playerTurn = gameRef.value(forKey: "playerTurn") as! Int
        if gameRef.value(forKey: "player\(playerTurn)") as! String == playerID {
            allowTurn()
        } else {
            disallowTurn()
        }
    }
    
    func allowTurn() {
    }
        
    func disallowTurn() {
        // make board unclickable
        blButton.isEnabled = false
    }
}

class TicTacToe {
    
}
