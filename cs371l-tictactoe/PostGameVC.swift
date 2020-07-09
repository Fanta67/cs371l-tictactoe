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
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var label: UILabel!
    var leftBarButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        label.text = match.value(forKeyPath: "whoWon") as? String
        let gameImageData = match.value(forKeyPath: "gameImage") as! Data
        imageView.image = UIImage(data: gameImageData)
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
        let activityViewController = UIActivityViewController(activityItems: [imageView.image!, self], applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        present(activityViewController, animated: true, completion: nil)
    }
    
    /// Displays the board image as the thumbnail when sharing.
    func activityViewControllerLinkMetadata(_ activityViewController: UIActivityViewController) -> LPLinkMetadata? {
        let image = imageView.image!
        let imageProvider = NSItemProvider(object: image)
        let metadata = LPLinkMetadata()
        let result = match.value(forKeyPath: "whoWon") as? String
        switch result {
        case "Victory":
            metadata.title = "I emerged victorious from a game of Tic Tac Toe!"
        case "Defeat":
            metadata.title = "I got messed up in Tic Tac Toe..."
        case "Draw":
            metadata.title = "Yet another uneventful game of Tic Tac Toe..."
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
