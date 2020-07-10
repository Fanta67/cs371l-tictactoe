//
//  SoloGameVC.swift
//  cs371l-tictactoe
//  EID: bv5433, dk9362
//  Course: CS371L
//
//  Created by Dylan Kan on 7/9/20.
//  Copyright © 2020 billyvo. All rights reserved.
//

import UIKit
import CoreData
import Foundation
import AVFoundation

class SoloGameVC: UIViewController {

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
    var endgamePlayer: AVAudioPlayer!
    var turn: Int?
    
    var finishedMatch: NSManagedObject!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        buttonArray = [button1, button2, button3, button4, button5, button6, button7, button8, button9]
        let sound = NSDataAsset(name: "click")!
        do {
            clickPlayer = try AVAudioPlayer(data: sound.data, fileTypeHint: "mp3")
        } catch {
            print("Failed to create AVAudioPlayer")
        }
        turn = 1
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
    
    /// Update board in database and change turn.
    @IBAction func buttonPressed(_ sender: Any) {
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
        if (self.turn == 1 && self.boardState[whichIdx] == 0) {
            self.boardState[whichIdx] = 1
            self.buttonArray[whichIdx].setImage(UIImage(named: "x.png"), for: .normal)
            self.turn = 2
            //play button click whenever board changes
            if (settings[1].value(forKeyPath: "isOn") as! Bool) {
                self.clickPlayer.prepareToPlay()
                self.clickPlayer.play()
            }
        } else if (self.turn == 2 && self.boardState[whichIdx] == 0){
            self.boardState[whichIdx] = 2
            self.buttonArray[whichIdx].setImage(UIImage(named: "o.png"), for: .normal)
            self.turn = 1
            //play button click whenever board changes
            if (settings[1].value(forKeyPath: "isOn") as! Bool) {
                self.clickPlayer.prepareToPlay()
                self.clickPlayer.play()
            }
        }
        checkForWin()
    }
    
    func checkForWin() {
        var emptySpace = false
        for i in 0..<boardState.count {
            if (boardState[i] == 0) {
                emptySpace = true
            }
        }
        //check for win
        for combination in self.winningCombinations {
            //if we find 3 of the same symbol in a row
            if (boardState[combination[0]] != 0 && boardState[combination[0]] == boardState[combination[1]] && boardState[combination[1]] == boardState[combination[2]]) {
                if (boardState[combination[0]] == 1) {
                    gameFinished(winner: "X Won!")
                    return
                } else if (boardState[combination[0]] == 2) {
                    gameFinished(winner: "O Won!")
                    return
                }
            }
        }
            
        //board is filled and no win, game is a draw
        if (!emptySpace) {
            gameFinished(winner: "Draw")
        }
    }
        
    /// Saves match to core data and transition to postgame.
    func gameFinished(winner: String) {
        let gameState = boardState as NSArray
        self.save(whoWon: winner, gameState: gameState)
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
        
        self.performSegue(withIdentifier: "SoloPostgameSegue", sender: nil)
    }
    
    //save match to core data
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
        if segue.identifier == "SoloPostgameSegue" {
            let destination = segue.destination as! PostGameVC
            destination.match = finishedMatch
            destination.changeBackButtonToX()
        }
    }

}
