//
//  ViewController.swift
//  PictureSelector
//
//  Created by Robert on 04/08/16.
//  Copyright © 2016 IBM. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    var selectionModel: SelectionModel!{
        didSet{
            tableView.setDataSource(self)
            tableView.setDelegate(self)
        }
    }
    
    @IBOutlet weak var tableView: NSTableView!
    
    @IBOutlet weak var imageView: NSImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Do any additional setup after loading the view.
    }
    
    @IBOutlet weak var nonSelectedCheckbox: NSButton!
    @IBAction func nonSelectedClicked(sender: NSButton) {
    }
    
    @IBOutlet weak var selectedCheckBox: NSButton!
    
    @IBAction func nonSelectedButtonClicked(sender: NSButton) {
    }
    
    @IBAction func generateButtonClicked(sender: AnyObject) {
        self.initializeBasics()
    }
    
    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    func initializeBasics(){
        if let path = self.getTheFolderPathToBrowse(){
            selectionModel = SelectionModel(fromFolderPath: path)
        }
    }
    
    func getTheFolderPathToBrowse() -> NSURL?{
        
        var resultURL:NSURL? = nil
        
        let dialog = NSOpenPanel();
        dialog.title                   = "Choose a .txt file";
        dialog.showsResizeIndicator    = true;
        dialog.showsHiddenFiles        = false;
        dialog.canChooseDirectories    = true;
        dialog.canCreateDirectories    = true;
        dialog.allowsMultipleSelection = false;
        dialog.allowedFileTypes        = ["txt"];
        
        if (dialog.runModal() == NSModalResponseOK) {
            let result = dialog.URL // Pathname of the file
            print("result:\(result)")
            resultURL = result
        } else {
            // User clicked on "Cancel"
        }
        return resultURL
    }
}

extension ViewController: NSTableViewDataSource{
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return self.selectionModel.imageInformationArray.count
    }
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let fileDetails = self.selectionModel.imageInformationArray[row]
        switch tableColumn!.identifier {
        case "filename":
            
            if let cell = tableView.makeViewWithIdentifier("filename", owner: nil) as? NSTableCellView {
                if let filePath = fileDetails.filePath{
                    cell.textField?.stringValue = filePath.lastPathComponent ?? ""
                }
                return cell
            }
            
        case "selected":
            
            if let cell = tableView.makeViewWithIdentifier("checkbox", owner: nil) as? NSTableCellView {
                if let checkBox = cell.viewWithTag(1) as? NSButton{
                    checkBox.state = fileDetails.selected ? 1 : 0
                }
                return cell
            }
            
        default:
            break
        }
        
        return nil
    }

    
    
    
}

extension ViewController: NSTableViewDelegate{
    
}
