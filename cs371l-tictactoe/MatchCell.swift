//
//  Filename: MatchCell.swift
//  cs371l-tictactoe
//  EID: bv5433, dk9362
//  Course: CS371L
//
//  Created by Billy Vo and Dylan Kan on 6/22/20.
//  Copyright © 2020 billyvo and dylan.kan67. All rights reserved.
//

import UIKit
import CoreData

class MatchCell: UITableViewCell {

    @IBOutlet weak var panel1: UIImageView!
    @IBOutlet weak var panel2: UIImageView!
    @IBOutlet weak var panel3: UIImageView!
    @IBOutlet weak var panel4: UIImageView!
    @IBOutlet weak var panel5: UIImageView!
    @IBOutlet weak var panel6: UIImageView!
    @IBOutlet weak var panel7: UIImageView!
    @IBOutlet weak var panel8: UIImageView!
    @IBOutlet weak var panel9: UIImageView!
    @IBOutlet weak var boardImageView: UIImageView!
    @IBOutlet weak var whoWon: UILabel!
    
    // Sets board image (color) based on selected color scheme.
    func setBoardImage() {
        if(settings[0].value(forKeyPath: "isOn") as! Bool) {
            boardImageView.image = UIImage(named: "board-10pix-white-transparent")
        } else {
            boardImageView.image = UIImage(named: "board-10pix-black-transparent")
        }
    }
    
    // Sets other fields of the board's representation based on match from Core Data.
    func setFieldsFromCoreData(match: NSManagedObject) {
        setBoardImage()
        whoWon.text = match.value(forKey: "whoWon") as? String
        if (whoWon.text == "Defeat") {
            whoWon.textColor = .red
        } else if (whoWon.text == "Draw") {
            whoWon.textColor = .yellow
        }
        
        let gameStateArray = match.value(forKey: "gameState") as! [Int]
        let panelArray = [
            panel1, panel2, panel3,
            panel4, panel5, panel6,
            panel7, panel8, panel9,
        ]
        for i in 0 ..< gameStateArray.count {
            if (gameStateArray[i] == 1) {
                panelArray[i]!.image = UIImage(named: "x.png")!
            } else if (gameStateArray[i] == 2) {
                panelArray[i]!.image = UIImage(named: "o.png")!
            } else {
                panelArray[i]!.image = nil
            }
        }
    }
}
