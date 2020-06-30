//
//  SettingsVC.swift
//  cs371l-tictactoe
//  EID: bv5433, dk9362
//  Course: CS371L
//
//  Created by Dylan Kan on 6/21/20.
//  Copyright © 2020 billyvo. All rights reserved.
//

import UIKit
import CoreData

class SettingsVC: UIViewController {

    @IBOutlet weak var darkMode: UISwitch!
    @IBOutlet weak var soundOn: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let dark = settings[0]
        let sound = settings[1]
        darkMode.isOn = dark.value(forKeyPath: "isOn") as! Bool
        soundOn.isOn = sound.value(forKeyPath: "isOn") as! Bool
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if(settings[0].value(forKeyPath: "isOn") as! Bool) {
            overrideUserInterfaceStyle = .dark
        } else {
            overrideUserInterfaceStyle = .light
        }
    }
    
    @IBAction func toggleDarkMode(_ sender: Any) {
        save(which: 0, value: darkMode.isOn)
        if(settings[0].value(forKeyPath: "isOn") as! Bool) {
            overrideUserInterfaceStyle = .dark
        } else {
            overrideUserInterfaceStyle = .light
        }
    }
    
    @IBAction func toggleSound(_ sender: Any) {
        save(which: 1, value: soundOn.isOn)
    }
    
    func save(which: Int, value: Bool) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }

        let managedContext = appDelegate.persistentContainer.viewContext
        let object = settings[which]

        object.setValue(value, forKey: "isOn")

        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
            abort()
        }
    }
}
