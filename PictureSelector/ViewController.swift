//
//  ViewController.swift
//  PictureSelector
//
//  Created by Robert on 04/08/16.
//  Copyright © 2016 IBM. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    @IBOutlet weak var tableView: NSTableView!
    
    @IBOutlet weak var imageView: NSImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.setDataSource(self)
        tableView.setDelegate(self)
        
        // Do any additional setup after loading the view.
    }

    @IBOutlet weak var nonSelectedCheckbox: NSButton!
    @IBAction func nonSelectedClicked(sender: NSButton) {
    }
    
    @IBOutlet weak var selectedCheckBox: NSButton!
    
    @IBAction func nonSelectedButtonClicked(sender: NSButton) {
    }
    
    @IBAction func generateButtonClicked(sender: AnyObject) {
    }
    
    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }
}

extension ViewController: NSTableViewDataSource{
    
}

extension ViewController: NSTableViewDelegate{
    
}
