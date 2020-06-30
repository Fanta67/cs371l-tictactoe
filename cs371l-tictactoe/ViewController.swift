//
//  Filename: ViewController.swift
//  EID: bv5433, dk9362
//  Course: CS371L
//
//  Created by Billy Vo on 6/21/20.
//  Copyright © 2020 billyvo. All rights reserved.
//

import UIKit
import CoreData

//store darkMode and soundOn
public var settings:[NSObject] = []

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if (settings.count == 0) {
            saveDefaults()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        if(settings[0].value(forKeyPath: "isOn") as! Bool) {
            overrideUserInterfaceStyle = .dark
        } else {
            overrideUserInterfaceStyle = .light
        }
    }
    
    func saveDefaults() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "DarkMode", in: managedContext)!
        let darkMode = NSManagedObject(entity: entity, insertInto: managedContext)
        let entity2 = NSEntityDescription.entity(forEntityName: "Sound", in: managedContext)!
        let soundOn = NSManagedObject(entity: entity2, insertInto: managedContext)
        
        darkMode.setValue(false, forKey: "isOn")
        soundOn.setValue(true, forKey: "isOn")
        
        do {
            try managedContext.save()
            settings.append(darkMode)
            settings.append(soundOn)
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
            abort()
        }
    }
}

