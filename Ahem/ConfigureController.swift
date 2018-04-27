//
//  ConfigureController.swift
//  Ahem
//
//  Created by Brian Sanders on 4/25/18.
//  Copyright © 2018 Brian Sanders. All rights reserved.
//

import Cocoa


fileprivate let FeedConfigurationId = NSUserInterfaceItemIdentifier(rawValue: "FeedConfiguration")

class ConfigureController: NSViewController, NSTableViewDelegate, NSTableViewDataSource {
    @IBOutlet var label: NSTextField!
    @IBOutlet var feedConfigurations: NSTableView!
    
    var configs: [NSManagedObject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        feedConfigurations.delegate = self
        feedConfigurations.dataSource = self
//        feedConfigurations.
        print("Configuration done")
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        
        guard  let appDelegate = NSApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Subscription")
        
        do {
            configs = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return configs.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let item = feedConfigurations.makeView(withIdentifier: FeedConfigurationId, owner: nil)
        guard let configView = item as? FeedConfigurationView else { return item }
        
        let config = configs[row]
        configView.setConfig(config)
        return configView
    }
    
    func numberOfSections(in collectionView: NSCollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return configs.count
    }
}
