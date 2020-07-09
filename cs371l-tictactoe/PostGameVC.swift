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

class PostGameVC: UIViewController {
    
    var match: NSManagedObject!
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var label: UILabel!
    var leftBarButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        label.text = match.value(forKeyPath: "whoWon") as? String
        let gameImageData = match.value(forKeyPath: "gameImage") as! Data
        imageView.image = UIImage(data: gameImageData)
        //code to hide navigation bar
        //self.navigationController?.setNavigationBarHidden(false, animated: true)
        //self.navigationItem.setHidesBackButton(true, animated: true)
        
        /*
        let leftBarButton = UIBarButtonItem(image: UIImage(systemName: "xmark"), style: .plain, target: self, action: #selector(xMarkButtonPressed(_:)))
        
        navigationItem.setLeftBarButton(leftBarButton, animated: true)
 */

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
    
    func changeBackButtonToX() {
        let leftBarButton = UIBarButtonItem(image: UIImage(systemName: "xmark"), style: .plain, target: self, action: #selector(segueToMainMenu))
        navigationItem.setLeftBarButton(leftBarButton, animated: true)
    }

}
