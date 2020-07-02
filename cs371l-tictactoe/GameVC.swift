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
import CoreData
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
            self.navigationController?.navigationBar.barTintColor = .black
        } else {
            overrideUserInterfaceStyle = .light
            self.navigationController?.navigationBar.barTintColor = .white
        }
    }
    
    func save(whoWon: String, gameImage: UIImage) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Match", in: managedContext)!
        let match = NSManagedObject(entity: entity, insertInto: managedContext)
        
        match.setValue(whoWon, forKey: "whoWon")
        match.setValue(gameImage, forKey: "gameImage")
    
        do {
            try managedContext.save()
            matchTable.append(match)
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
            abort()
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
