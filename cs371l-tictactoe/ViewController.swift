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
public var settings:[NSManagedObject] = []

class ViewController: UIViewController {

    @IBOutlet weak var titleImageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
              return
        }
        
        //fetch settings from core data
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
        
//        DeleteAllData()
//        DeleteMatchData()
        
        //first time opening app and nothing in core data
        if (settings.count == 0) {
            saveDefaults()
        }
    }

//    //clear out settings in core data on load for easier testing
//    func DeleteAllData(){
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
//    //clear out settings in core data on load for easier testing
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
    
    //save default settings value to core data on first launch
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

