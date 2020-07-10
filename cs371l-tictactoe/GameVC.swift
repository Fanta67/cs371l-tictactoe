//
//  Filename: GameVC.swift
//  cs371l-tictactoe
//  EID: bv5433, dk9362
//  Course: CS371L
//
//  Created by Billy Vo and Dylan Kan on 6/22/20.
//  Copyright © 2020 billyvo and dylan.kan67. All rights reserved.
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
    
    var clickPlayer: AVAudioPlayer!
    var endgamePlayer: AVAudioPlayer!
    
    var boardObserverHandle: UInt = 0
    var turnObserverHandle: UInt = 0
    
    var inviteCode: String = ""
    var playerID: String = ""
    var finishedMatch: NSManagedObject!
    // A reference to the current game.
    var gameRef: DatabaseReference = Database.database().reference()
        
    // Find current game in the database and attach observers.
    override func viewDidLoad() {
        super.viewDidLoad()
        title = inviteCode
        gameRef = Database.database().reference().child("games/\(inviteCode)")
        buttonArray = [button1, button2, button3, button4, button5, button6, button7, button8, button9]
        let sound = NSDataAsset(name: "click")!
        do {
            clickPlayer = try AVAudioPlayer(data: sound.data, fileTypeHint: "mp3")
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
    
    
    override func viewWillDisappear(_ animated: Bool) {
        // Removes observers, will be re-added when viewDidLoad is called again.
        gameRef.child("board").removeObserver(withHandle: boardObserverHandle)
        gameRef.child("playerTurn").removeObserver(withHandle: turnObserverHandle)
    }
    
    // Allow player to click buttons.
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
        var symbol = "X"
        if (playerID == "player2Name") {
            symbol = "O"
        }
        turnLabel.text = "Your turn! (\(symbol))"
    }
    
    // Disallow player from clicking buttons.
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
    
    // Update board in database and change turn.
    @IBAction func buttonPressed(_ sender: Any) {
        let button = sender as? UIButton
        // Figure out which button was pressed.
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
        
        // Update database values based on button press index.
        gameRef.child("board/\(whichIdx)").observeSingleEvent(of: .value, with: { (snapshot) in
            let currVal = snapshot.value as! Int
            if (self.playerID == "player1Name" && currVal == 0) {
                self.gameRef.child("board/\(whichIdx)").setValue(1)
                self.gameRef.child("playerTurn").setValue(2)
            } else if (self.playerID == "player2Name" && currVal == 0){
                self.gameRef.child("board/\(whichIdx)").setValue(2)
                self.gameRef.child("playerTurn").setValue(1)
            }
        })
    }
    
    // Saves match to Core Data and segue to postgame.
    func gameFinished(didWin: Int) {
        
        if currentClientGame == inviteCode {
            currentClientGame = ""
        }
        if currentHostGame == inviteCode {
            currentHostGame = ""
        }
        
        // Removing observers to prevent database changes from invoking function calls.
        gameRef.child("board").removeObserver(withHandle: boardObserverHandle)
        gameRef.child("playerTurn").removeObserver(withHandle: turnObserverHandle)
    
        gameRef.child("board").observeSingleEvent(of: .value, with: { (snapshot) in
            let gameState = snapshot.value as! NSArray
            if (didWin == 1) {
                self.save(whoWon: "Victory", gameState: gameState)
                let sound = NSDataAsset(name: "victory")!
                do {
                    if (settings[1].value(forKeyPath: "isOn") as! Bool) {
                        self.endgamePlayer = try AVAudioPlayer(data: sound.data, fileTypeHint: "mp3")
                        self.endgamePlayer.prepareToPlay()
                        self.endgamePlayer.play()
                    }
                } catch {
                    print("Failed to create AVAudioPlayer")
                }
            } else if (didWin == 0) {
                self.save(whoWon: "Defeat", gameState: gameState)
                let sound = NSDataAsset(name: "defeat")!
                do {
                    if (settings[1].value(forKeyPath: "isOn") as! Bool) {
                        self.endgamePlayer = try AVAudioPlayer(data: sound.data, fileTypeHint: "mp3")
                        self.endgamePlayer.prepareToPlay()
                        self.endgamePlayer.play()
                    }
                } catch {
                    print("Failed to create AVAudioPlayer")
                }
            } else {
                self.save(whoWon: "Draw", gameState: gameState)
            }
            self.performSegue(withIdentifier: "PostgameSegue", sender: nil)
        })
    }
    
    // Save match to Core Data.
    func save(whoWon: String, gameState: NSArray) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Match", in: managedContext)!
        let match = NSManagedObject(entity: entity, insertInto: managedContext)
        match.setValue(gameState, forKey: "gameState")
        match.setValue(whoWon, forKey: "whoWon")
        self.finishedMatch = match
        
        do {
            try managedContext.save()
            matchTable.append(match)
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
            abort()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PostgameSegue" {
            let destination = segue.destination as! PostGameVC
            destination.match = finishedMatch
            destination.changeBackButtonToX()
        }
    }
    
    // Attaches observers to database's current board and playerTurn.
    // Observers execute code specified by with: every time the observed data is changed.
    func attachObserversToBoard() {
        
        // Attaching board observer.
        boardObserverHandle = gameRef.child("board").observe(DataEventType.value, with: { (snapshot) in
            // Casts snapshot as an array.
            guard let board = snapshot.value as? NSMutableArray else {
                print("Error: Casting Board As Array")
                return
            }
            // Play button click whenever board changes.
            if (settings[1].value(forKeyPath: "isOn") as! Bool) {
                self.clickPlayer.prepareToPlay()
                self.clickPlayer.play()
            }
            // Update board images.
            let boardAsArray = board as! [Int]
            var emptySpace = false
            for i in 0..<boardAsArray.count {
                if (boardAsArray[i] == 1) {
                    self.buttonArray[i].setImage(UIImage(named: "x.png"), for: .normal)
                } else if (boardAsArray[i] == 2) {
                    self.buttonArray[i].setImage(UIImage(named: "o.png"), for: .normal)
                } else {
                    emptySpace = true
                    self.buttonArray[i].setImage(nil, for: .normal)
                }
            }
            
            // Check for win conditions.
            for combination in self.winningCombinations {
                // If we find 3 of the same symbol in a row.
                if (boardAsArray[combination[0]] != 0 && boardAsArray[combination[0]] == boardAsArray[combination[1]] && boardAsArray[combination[1]] == boardAsArray[combination[2]]) {
                    if (boardAsArray[combination[0]] == 1 && self.playerID == "player1Name") || (boardAsArray[combination[0]] == 2 && self.playerID == "player2Name") {
                        self.gameFinished(didWin: 1)
                        return
                    } else {
                        self.gameFinished(didWin: 0)
                        return
                    }
                }
            }
            
            // Board is filled and no win, game is a draw.
            if (!emptySpace) {
                self.gameFinished(didWin: 2)
            }
        })
        
        // Attaching playerTurn observer. It automatically disables/enables turn
        // based on if playerID matches playerTurn.
        turnObserverHandle = gameRef.child("playerTurn").observe(DataEventType.value, with: { (snapshot) in
            let playerTurn = (snapshot.value as? Int)!
            if self.playerID == "player\(playerTurn)Name" {
                self.allowTurn()
            } else {
                self.disallowTurn()
            }
        })
    }
}
