//
//  FeedConfigurationView.swift
//  Ahem
//
//  Created by Brian Sanders on 4/26/18.
//  Copyright © 2018 Brian Sanders. All rights reserved.
//

import Cocoa

class FeedConfigurationView: NSTableCellView {
    @IBAction func gotText(_ sender: NSTextField) {
        print(sender.stringValue)
    }
    
    func setConfig(_ config: NSManagedObject) {
        textField?.stringValue = (config.value(forKeyPath: "url") as? String) ?? ""
    }
}
