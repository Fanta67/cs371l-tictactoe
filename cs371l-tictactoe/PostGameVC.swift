//
//  Filename: PostGameVC.swift
//  cs371l-tictactoe
//  EID: bv5433, dk9362
//  Course: CS371L
//
//  Created by Billy Vo and Dylan Kan on 6/22/20.
//  Copyright © 2020 billyvo and dylan.kan67. All rights reserved.
//

import UIKit
import CoreData
import LinkPresentation

class PostGameVC: UIViewController, UIActivityItemSource {
    
    var leftBarButton: UIBarButtonItem!
    var screenshot: UIImage!
    var match: NSManagedObject!
    
    @IBOutlet weak var boardView: UIView!
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        label.text = match.value(forKeyPath: "whoWon") as? String
        setImagesFromCoreData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        changeViewBasedOnColorMode()
    }
    
    // Set images of match-representing board based on match from Core Data.
    func setImagesFromCoreData() {
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

    // Segues to Main Menu (ViewController), to be used by the X button in Navigation Bar.
    @objc func segueToMainMenu() {
        performSegue(withIdentifier: "PostgameToMainMenuSegue", sender: nil)
    }
    
    // Changes the Navigation Bar's back button to be an X. Called when segued from GameVC.
    func changeBackButtonToX() {
        let leftBarButton = UIBarButtonItem(image: UIImage(systemName: "xmark"), style: .plain, target: self, action: #selector(segueToMainMenu))
        navigationItem.setLeftBarButton(leftBarButton, animated: true)
    }

    // Creates an UIActiviyViewController to share an image of the match's board.
    @IBAction func shareButtonPressed(_ sender: Any) {
        screenshot = screenshotOfArea(view: boardView, bounds: boardView.bounds)
        let activityViewController = UIActivityViewController(activityItems: [screenshot!, self], applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        present(activityViewController, animated: true, completion: nil)
    }
    
    // Displays the board image as the thumbnail and provides description when sharing.
    func activityViewControllerLinkMetadata(_ activityViewController: UIActivityViewController) -> LPLinkMetadata? {
        let image = screenshot!
        let imageProvider = NSItemProvider(object: image)
        let metadata = LPLinkMetadata()
        let result = match.value(forKeyPath: "whoWon") as? String
        switch result {
        case "Victory":
            metadata.title = "I emerged victorious from Tic Tac Toe!"
        case "Defeat":
            metadata.title = "I got messed up in Tic Tac Toe."
        case "Draw":
            metadata.title = "Another uneventful game of Tic Tac Toe."
        default:
            metadata.title = "Tic Tac Toe"
        }
        metadata.imageProvider = imageProvider
        return metadata
    }
    
    // Function to conform to UIActivityItemSource.
    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return ""
    }
    
    // Function to conform to UIActivityItemSource.
    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        return nil
    }
    
    // Changes view to light/dark mode based on setting.
    func changeViewBasedOnColorMode() {
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
    
    /// Takes a screenshot of specified area and returns it as a UIImage.
    ///
    /// - Parameters:
    ///   - view: The UIView to take a screenshot of, must have graphical elements in it's hierarchy.
    ///   - bounds: The CGRect to denote the framing of the screenshot.
    func screenshotOfArea(view: UIView, bounds: CGRect? = nil) -> UIImage {
        let screenshotRect = CGRect(x: 20, y: 200, width: 374, height: 374)
        
        // Temporarily change view to light mode before screenshot.
        // Allow turn to prevent button greying.
        overrideUserInterfaceStyle = .light
        self.navigationController?.navigationBar.barTintColor = .white
        boardImageView.image = UIImage(named: "board-10pix-black-transparent")

        let result = UIGraphicsImageRenderer(bounds: bounds ?? screenshotRect).image { _ in
            view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
        }
        
        changeViewBasedOnColorMode()
        
        return result
    }
}
