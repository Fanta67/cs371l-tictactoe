//
//  Filename: SettingsVC.swift
//  cs371l-tictactoe
//  EID: bv5433, dk9362
//  Course: CS371L
//
//  Created by Billy Vo and Dylan Kan on 6/22/20.
//  Copyright © 2020 billyvo and dylan.kan67. All rights reserved.
//

import UIKit
import CoreData
import AVFoundation

class SettingsVC: UIViewController {

    @IBOutlet weak var darkMode: UISwitch!
    @IBOutlet weak var soundOn: UISwitch!
    var clickPlayer: AVAudioPlayer!

    // Set up initial states of switches and create audio player.
    override func viewDidLoad() {
        super.viewDidLoad()
        let dark = settings[0]
        let sound = settings[1]
        darkMode.isOn = dark.value(forKeyPath: "isOn") as! Bool
        soundOn.isOn = sound.value(forKeyPath: "isOn") as! Bool
        
        let soundFile = NSDataAsset(name: "click")!
        do {
            clickPlayer = try AVAudioPlayer(data: soundFile.data, fileTypeHint: "mp3")
        } catch {
            print("Failed to create AVAudioPlayer")
        }
    }
    
    // Open with dark mode or light mode.
    override func viewWillAppear(_ animated: Bool) {
        if(settings[0].value(forKeyPath: "isOn") as! Bool) {
            overrideUserInterfaceStyle = .dark
            self.navigationController?.navigationBar.barTintColor = .black
        } else {
            overrideUserInterfaceStyle = .light
            self.navigationController?.navigationBar.barTintColor = .white
        }
    }
    
    // Play click sound and save to Core Data.
    @IBAction func toggleDarkMode(_ sender: Any) {
        if(settings[1].value(forKeyPath: "isOn") as! Bool) {
            clickPlayer.prepareToPlay()
            clickPlayer.play()
        }
        save(which: 0, value: darkMode.isOn)
        if(settings[0].value(forKeyPath: "isOn") as! Bool) {
            overrideUserInterfaceStyle = .dark
            self.navigationController?.navigationBar.barTintColor = .black
        } else {
            overrideUserInterfaceStyle = .light
            self.navigationController?.navigationBar.barTintColor = .white
        }
    }
    
    // Play click sound if we toggle on.
    @IBAction func toggleSound(_ sender: Any) {
        save(which: 1, value: soundOn.isOn)
        if(settings[1].value(forKeyPath: "isOn") as! Bool) {
            clickPlayer.prepareToPlay()
            clickPlayer.play()
        }
    }
    
    // Save setting to Core Data.
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
