//
//  Filename: ViewController.swift
//  cs371l-tictactoe
//  EID: bv5433, dk9362
//  Course: CS371L
//
//  Created by Billy Vo and Dylan Kan on 6/22/20.
//  Copyright © 2020 billyvo and dylan.kan67. All rights reserved.
//

import UIKit
import CoreData

// Store darkMode and soundOn.
public var settings:[NSManagedObject] = []

class ViewController: UIViewController {

    @IBOutlet weak var titleImageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
              return
        }
        
        // Fetch settings from core data.
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "DarkMode")
        let fetchRequest2 = NSFetchRequest<NSManagedObject>(entityName: "Sound")
        
        do {
            let darkMode = try managedContext.fetch(fetchRequest)
            let soundOn = try managedContext.fetch(fetchRequest2)
            if darkMode.count > 0 {
                try settings.append(managedContext.fetch(fetchRequest)[0])
            }
            if soundOn.count > 0 {
                try settings.append(managedContext.fetch(fetchRequest2)[0])
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
            abort()
        }
        
//        // Methods for deleting Core Data data.
//        DeleteAllData()
//        DeleteMatchData()
        
        // First time opening app and nothing in core data.
        if (settings.count == 0) {
            saveDefaults()
        }
    }

//    // Clears out settings data in Core Data on load for easier testing.
//    func DeleteAllData() {
//        let appDelegate = UIApplication.shared.delegate as! AppDelegate
//        let managedContext = appDelegate.persistentContainer.viewContext
//        let DelAllReqVar = NSBatchDeleteRequest(fetchRequest: NSFetchRequest<NSFetchRequestResult>(entityName: "DarkMode"))
//        let DelAllReqVar2 = NSBatchDeleteRequest(fetchRequest: NSFetchRequest<NSFetchRequestResult>(entityName: "Sound"))
//        do {
//            try managedContext.execute(DelAllReqVar)
//            try managedContext.execute(DelAllReqVar2)
//        }
//        catch {
//            print(error)
//        }
//    }
//
//    // Clears out match data in Core Data on load for easier testing.
//    func DeleteMatchData(){
//        let appDelegate = UIApplication.shared.delegate as! AppDelegate
//        let managedContext = appDelegate.persistentContainer.viewContext
//        let DelAllReqVar = NSBatchDeleteRequest(fetchRequest: NSFetchRequest<NSFetchRequestResult>(entityName: "Match"))
//        do {
//            try managedContext.execute(DelAllReqVar)
//        }
//        catch {
//            print(error)
//        }
//    }

    override func viewWillAppear(_ animated: Bool) {
        if(settings[0].value(forKeyPath: "isOn") as! Bool) {
            overrideUserInterfaceStyle = .dark
            self.navigationController?.navigationBar.barTintColor = .black
            titleImageView.image = UIImage(named: "title-board-white-transparent")
        } else {
            overrideUserInterfaceStyle = .light
            self.navigationController?.navigationBar.barTintColor = .white
            titleImageView.image = UIImage(named: "title-board-black-transparent")
        }
    }
    
    // Save default settings value to Core Data on first launch.
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

