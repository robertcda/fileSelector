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
        
        imageView.autoresizingMask =  [.ViewHeightSizable,.ViewWidthSizable]
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
    @IBAction func saveButtonClicked(sender: NSButton) {
        self.selectionModel.save()
    }
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return self.selectionModel.imageInformationArray.count
    }
    
    func tableView(tableView: NSTableView!, objectValueForTableColumn tableColumn: NSTableColumn!, row: Int) -> AnyObject!{
        var objectValue: AnyObject = ""
        
        let fileDetails = self.selectionModel.imageInformationArray[row]
        switch tableColumn!.identifier {
        case "filename":
            
                if let filePath = fileDetails.filePath{
                    objectValue = filePath.lastPathComponent ?? ""
                }
            
        case "selected":
            objectValue = fileDetails.selected ? 1 : 0
            
        default:
            break
        }
        
        return objectValue
    }
}

extension ViewController: NSTableViewDelegate{
    func tableViewSelectionDidChange(notification: NSNotification) {
        print("\(#function)")
        let selectedIndex = tableView.selectedRowIndexes.firstIndex
        if selectedIndex != NSNotFound{
            let selectedImgDetails = self.selectionModel.imageInformationArray[selectedIndex]
            if let fileURL = selectedImgDetails.filePath, let image = NSImage(contentsOfURL: fileURL){
                imageView.imageScaling = .ScaleProportionallyUpOrDown
                imageView.image = image
            }
        }else{
            imageView.image = nil
        }
        
    }
}
