//
//  AppDelegate.swift
//  Ahem
//
//  Created by Brian Sanders on 4/23/18.
//  Copyright © 2018 Brian Sanders. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!
    var persistentContainer: NSPersistentContainer!

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let container = NSPersistentContainer(name: "Feeds")
        container.loadPersistentStores { (description, error) in
            if let error = error {
                fatalError("Unable to load store: \(error)")
            } else {
                print("\(description)")
            }
        }
        
        persistentContainer = container
        let view = ConfigureController()
        window.contentView = view.view
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

