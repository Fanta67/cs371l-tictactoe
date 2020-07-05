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
    
    @IBOutlet weak var button1: UIButton!
    @IBOutlet weak var button2: UIButton!
    @IBOutlet weak var button3: UIButton!
    @IBOutlet weak var button4: UIButton!
    @IBOutlet weak var button5: UIButton!
    @IBOutlet weak var button6: UIButton!
    @IBOutlet weak var button7: UIButton!
    @IBOutlet weak var button8: UIButton!
    @IBOutlet weak var button9: UIButton!
    @IBOutlet weak var turnLabel: UILabel!
    let winningCombinations = [[0, 1, 2], [3, 4, 5], [6, 7, 8], [0, 3, 6], [1, 4, 7], [2, 5, 8], [0, 4, 8], [2, 4, 6]]
    
    var inviteCode: String = ""
    var playerID: String = ""
    // A reference to the current game.
    var gameRef: DatabaseReference = Database.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        gameRef = Database.database().reference().child("game/\(inviteCode)")
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
    
    //save match to core data
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
        button1.isEnabled = true
        button2.isEnabled = true
        button3.isEnabled = true
        button4.isEnabled = true
        button5.isEnabled = true
        button6.isEnabled = true
        button7.isEnabled = true
        button8.isEnabled = true
        button9.isEnabled = true
        turnLabel.text = "Your turn!"
    }
        
    func disallowTurn() {
        button1.isEnabled = false
        button2.isEnabled = false
        button3.isEnabled = false
        button4.isEnabled = false
        button5.isEnabled = false
        button6.isEnabled = false
        button7.isEnabled = false
        button8.isEnabled = false
        button9.isEnabled = false
        turnLabel.text = "Opponent's turn!"
    }
    
    @IBAction func buttonPressed(_ sender: Any) {
        let button = sender as? UIButton
        var whichIdx = -1
        switch button {
        case button1:
            whichIdx = 0
        case button2:
            whichIdx = 1
        case button3:
            whichIdx = 2
        case button4:
            whichIdx = 3
        case button5:
            whichIdx = 4
        case button6:
            whichIdx = 5
        case button7:
            whichIdx = 6
        case button8:
            whichIdx = 7
        case button9:
            whichIdx = 8
        default:
            print("This shouldn't happen")
            abort()
        }
        print("\(whichIdx)")
        button?.setImage(UIImage(named: "o.png"), for: .normal)
        for combination in winningCombinations {
            //check if game has been won
            break
        }
        
//        var image: UIImage = self.view.boardScreenshot()
//        button?.setBackgroundImage(image, for: .normal)
    }
    
    func gameFinished() {
        gameRef.child("playerTurn").removeAllObservers()
        gameRef.child("board").removeAllObservers()
        performSegue(withIdentifier: "PostgameSegue", sender: nil)
    }
    
    /// Attaches observers to database's current board and playerTurn. Observers execute code specified
    /// by the with: parameter every time data being observed is changed.
    func attachObserversToBoard() {
        
        // Attaching board observer.
        gameRef.child("board").observe(DataEventType.value, with: { (snapshot) in
            // Casts snapshot as an array
            guard let boardAsArray = snapshot.value as? NSMutableArray else {
                print("CASTING BOARD AS ARRAY ERROR")
                return
            }
            for i in 0 ..< 9 {
                //if boardAsArray[i] == 1 ; button[i].setAsX
                //else if == 2; button[i].setAsCircle
            }
            //self.gameRef.updateChildValues(boardDict)
        })
        
        // Attaching playerTurn observer. It automatically disables/enables turn
        // based on if playerID matches playerTurn.
        gameRef.child("playerTurn").observe(DataEventType.value, with: { (snapshot) in
            let playerTurn = (snapshot.value as? Int)!
            if self.playerID == "player\(playerTurn)Name" {
                self.allowTurn()
            } else {
                self.disallowTurn()
            }
        })
    }
        
}

extension UIView {
    
    /// Takes a screenshot of the tictactoe board and returns it as a UIImage.
    // TODO: currently not sized correctly!
    func boardScreenshot() -> UIImage {
    return UIGraphicsImageRenderer(size: bounds.size).image { _ in
        let rectangle = CGRect(x: 20, y: 184, width: 130*3, height: 130*3)
        drawHierarchy(in: rectangle, afterScreenUpdates: true)
        }
    }
    
}
