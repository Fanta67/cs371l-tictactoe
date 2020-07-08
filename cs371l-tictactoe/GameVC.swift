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
import AVFoundation

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
    @IBOutlet weak var boardImageView: UIImageView!
    @IBOutlet weak var boardView: UIView!
    var buttonArray: [UIButton] = []
    let winningCombinations = [[0, 1, 2], [3, 4, 5], [6, 7, 8], [0, 3, 6], [1, 4, 7], [2, 5, 8], [0, 4, 8], [2, 4, 6]]
    var boardState = [0, 0, 0, 0, 0, 0, 0, 0, 0]
    var clickPlayer: AVAudioPlayer!
    
    var inviteCode: String = ""
    var playerID: String = ""
    // A reference to the current game.
    var gameRef: DatabaseReference = Database.database().reference()
    
    //find current game in the database
    override func viewDidLoad() {
        super.viewDidLoad()
        gameRef = Database.database().reference().child("games/\(inviteCode)")
        buttonArray = [button1, button2, button3, button4, button5, button6, button7, button8, button9]
        let sound = NSDataAsset(name: "click")!
        do {
            if (settings[1].value(forKeyPath: "isOn") as! Bool) {
                clickPlayer = try AVAudioPlayer(data: sound.data, fileTypeHint: "mp3")
            }
        } catch {
            print("Failed to create AVAudioPlayer")
        }
        attachObserversToBoard()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if(settings[0].value(forKeyPath: "isOn") as! Bool) {
            overrideUserInterfaceStyle = .dark
            self.navigationController?.navigationBar.barTintColor = .black
            boardImageView.image = UIImage(named: "board-10pix-white-transparent")
        } else {
            overrideUserInterfaceStyle = .light
            self.navigationController?.navigationBar.barTintColor = .white
            boardImageView.image = UIImage(named: "board-10pix-black-transparent")
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
        if (clickPlayer != nil) {
            clickPlayer.prepareToPlay()
            clickPlayer.play()
        }
        let button = sender as? UIButton
        //figure out which button was rpessed
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
        if (playerID == "player1Name") {
            gameRef.child("board/\(whichIdx)").setValue(1)
            gameRef.child("playerTurn").setValue(2)
        } else {
            gameRef.child("board/\(whichIdx)").setValue(2)
            gameRef.child("playerTurn").setValue(1)
        }
    }
    
    func gameFinished(didWin: Bool) {
        
        // Removing observers to prevent database changes from invoking function calls.
        gameRef.child("playerTurn").removeAllObservers()
        gameRef.child("board").removeAllObservers()
        
        // Taking screenshot
        // TODO: save screenshot to CoreData
        let absoluteBounds = boardImageView.convert(boardImageView.bounds, to: self.view)
        let image: UIImage = screenshotOfArea(view: self.view, bounds: absoluteBounds)
        if (didWin) {
            save(whoWon: "Victory", gameImage: image)
        } else {
            save(whoWon: "Defeat", gameImage: image)
        }
        
        performSegue(withIdentifier: "PostgameSegue", sender: nil)
    }
    
    /// Attaches observers to database's current board and playerTurn. Observers execute code specified
    /// by the with: parameter every time data being observed is changed.
    func attachObserversToBoard() {
        
        // Attaching board observer.
        gameRef.child("board").observe(DataEventType.value, with: { (snapshot) in
            // Casts snapshot as an array
            guard let board = snapshot.value as? NSMutableArray else {
                print("CASTING BOARD AS ARRAY ERROR")
                return
            }
            let boardAsArray = board as! [Int]
            for i in 0..<boardAsArray.count {
                if (boardAsArray[i] == 1) {
                    self.buttonArray[i].setImage(UIImage(named: "x.png"), for: .normal)
                } else if (boardAsArray[i] == 2) {
                    self.buttonArray[i].setImage(UIImage(named: "o.png"), for: .normal)
                } else {
                    self.buttonArray[i].setImage(nil, for: .normal)
                }
            }
            
            //check for win
            for combination in self.winningCombinations {
                //if we find 3 of the same symbol in a row
                if (boardAsArray[combination[0]] != 0 && boardAsArray[combination[0]] == boardAsArray[combination[1]] && boardAsArray[combination[1]] == boardAsArray[combination[2]]) {
                    if (boardAsArray[combination[0]] == 1 && self.playerID == "player1Name") || (boardAsArray[combination[0]] == 2 && self.playerID == "player2Name") {
                        self.gameFinished(didWin: true)
                    } else {
                        self.gameFinished(didWin: false)
                    }
                }
            }
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
    
    /// Takes a screenshot of specified area and returns it as a UIImage.
    ///
    /// - Parameters:
    ///   - view: The UIView to take a screenshot of, must have graphical elements in it's hierarchy.
    ///   - bounds: The CGRect to denote the framing of the screenshot.
    func screenshotOfArea(view: UIView, bounds: CGRect? = nil) -> UIImage {
        let screenshotRect = CGRect(x: 20, y: 200, width: 374, height: 374)
        return UIGraphicsImageRenderer(bounds: bounds ?? screenshotRect).image { _ in
            view.drawHierarchy(in: view.bounds, afterScreenUpdates: false)
        }
    }
}

/*
/// Extension allows a screenshot to be taken of a UIView.
extension UIView {
    
    /// Take a screenshot of the UIView using its bounds.
    func screenshot() -> UIImage {
        return UIGraphicsImageRenderer(bounds: self.bounds).image { _ in
            drawHierarchy(in: self.bounds, afterScreenUpdates: false)
        }
    }
    
}
*/
