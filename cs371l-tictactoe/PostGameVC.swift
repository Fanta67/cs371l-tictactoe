//
//  PostGameVC.swift
//  cs371l-tictactoe
//  EID: bv5433, dk9362
//  Course: CS371L
//
//  Created by Dylan Kan on 6/22/20.
//  Copyright © 2020 billyvo. All rights reserved.
//

import UIKit
import CoreData
import LinkPresentation

class PostGameVC: UIViewController, UIActivityItemSource {
    
    var match: NSManagedObject!
    
    @IBOutlet weak var boardImageView: UIImageView!
    @IBOutlet weak var panel1: UIImageView!
    @IBOutlet weak var panel2: UIImageView!
    @IBOutlet weak var panel3: UIImageView!
    @IBOutlet weak var panel4: UIImageView!
    @IBOutlet weak var panel5: UIImageView!
    @IBOutlet weak var panel6: UIImageView!
    @IBOutlet weak var panel7: UIImageView!
    @IBOutlet weak var panel8: UIImageView!
    @IBOutlet weak var panel9: UIImageView!
    @IBOutlet weak var label: UILabel!
    var leftBarButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        label.text = match.value(forKeyPath: "whoWon") as? String
        let gameImageData = match.value(forKeyPath: "gameImage") as! Data
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if(settings[0].value(forKeyPath: "isOn") as! Bool) {
            overrideUserInterfaceStyle = .dark
            self.navigationController?.navigationBar.barTintColor = .black
            boardImageView.image = UIImage(data: "board-10pix-white-transparent")
        } else {
            overrideUserInterfaceStyle = .light
            self.navigationController?.navigationBar.barTintColor = .white
            boardImageView.image = UIImage(data: "board-10pix-white-transparent")
        }
    }
    
    func setImagesFromCoreData() {
        let gameStateArray = match.value(forKey: "gameState") as! [Int]
        let imageViewArray = [
            panel1, panel2, panel3,
            panel4, panel5, panel6,
            panel7, panel8, panel9,
        ]
        for i in 0 ..< gameStateArray.count {
            if (gameStateArray[i] == 1) {
                panelArray[i]!.image = UIImage(named: "x.png")!
            } else if (gameStateArray[i] == 2) {
                panelArray[i]!.image = UIImage(named: "o.png")!
                panelArray[i]!.image = UIImage(named: "board-10pix-white-transparent")

            } else {
                panelArray[i]!.image = nil
            }
        }
    }

    
    @objc func segueToMainMenu() {
        performSegue(withIdentifier: "PostgameToMainMenuSegue", sender: nil)
    }
    
    /// Changes the Navigation Bar's back button to be an X. Called when segued from GameVC.
    func changeBackButtonToX() {
        let leftBarButton = UIBarButtonItem(image: UIImage(systemName: "xmark"), style: .plain, target: self, action: #selector(segueToMainMenu))
        navigationItem.setLeftBarButton(leftBarButton, animated: true)
    }

    /// Creates an UIActiviyViewController to share an image of the match's board.
    @IBAction func shareButtonPressed(_ sender: Any) {
        let activityViewController = UIActivityViewController(activityItems: [boardImageView.image!, self], applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        present(activityViewController, animated: true, completion: nil)
    }
    
    /// Displays the board image as the thumbnail when sharing.
    func activityViewControllerLinkMetadata(_ activityViewController: UIActivityViewController) -> LPLinkMetadata? {
        let image = boardImageView.image!
        let imageProvider = NSItemProvider(object: image)
        let metadata = LPLinkMetadata()
        let result = match.value(forKeyPath: "whoWon") as? String
        switch result {
        case "Victory":
            metadata.title = "I emerged victorious from Tic Tac Toe!"
        case "Defeat":
            metadata.title = "I got messed up in Tic Tac Toe"
        case "Draw":
            metadata.title = "Another uneventful game of Tic Tac Toe"
        default:
            metadata.title = "Tic Tac Toe"
        }
        metadata.imageProvider = imageProvider
        return metadata
    }
    
    // Functions to conform to UIActivityItemSource
    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return ""
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        return nil
    }
}
