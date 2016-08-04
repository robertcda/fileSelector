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
            self.refreshLocalModel()

            tableView.setDataSource(self)
            tableView.setDelegate(self)
        }
    }
    
    var filteredArrayOfFileInfos:[FileInformation] = [FileInformation](){
        didSet{
            self.tableView.reloadData()
        }
    }
    func refreshLocalModel(){
        for imgInfo in self.selectionModel.imageInformationArray{
            self.filteredArrayOfFileInfos.append(imgInfo)
        }
    }
    
    @IBOutlet weak var fileDescriptionLabel: NSTextField!
    @IBOutlet weak var tableView: NSTableView!
    
    @IBOutlet weak var imageView: NSImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        imageView.autoresizingMask =  [.ViewNotSizable]
        // Do any additional setup after loading the view.
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
    
    //MARK:- outlets and Actions
    
    @IBOutlet weak var nonSelectedCheckbox: NSButton!
    @IBAction func nonSelectedClicked(sender: NSButton) {
    }
    
    @IBOutlet weak var selectedCheckBox: NSButton!
    
    @IBAction func nonSelectedButtonClicked(sender: NSButton) {
    }
    
    @IBAction func selectFolderButtonClicked(sender: AnyObject) {
        self.initializeBasics()
    }

    
    @IBAction func saveButtonClicked(sender: NSButton) {
        
        let pasteboard = NSPasteboard.generalPasteboard()
        pasteboard.declareTypes([NSPasteboardTypeString], owner: nil)
        pasteboard.setString(self.selectionModel.selectedFilesInText(), forType: NSPasteboardTypeString)
        
        
    }

}

extension ViewController: NSTableViewDataSource{
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return self.filteredArrayOfFileInfos.count
    }
    
    func tableView(tableView: NSTableView!, objectValueForTableColumn tableColumn: NSTableColumn!, row: Int) -> AnyObject!{
        var objectValue: AnyObject = ""
        
        let fileDetails = self.filteredArrayOfFileInfos[row]
        switch tableColumn!.identifier {
        case "filename":
            
                if let filePath = fileDetails.fileURL{
                    objectValue = filePath.lastPathComponent ?? ""
                }
            
        case "selected":
            objectValue = fileDetails.selected ? 1 : 0
            
        case "group":
            objectValue = fileDetails.group
            
        default:
            break
        }
        
        return objectValue
    }
    
    func tableView(tableView: NSTableView, setObjectValue object: AnyObject?, forTableColumn tableColumn: NSTableColumn?, row: Int) {

        let fileDetails = self.filteredArrayOfFileInfos[row]

        switch tableColumn!.identifier {
        case "selected":
            if let numberValue = object as? NSNumber{
                fileDetails.selected = numberValue.boolValue
                self.selectionModel.save()
            }
        case "group":
            if let groupName = object as? String{
                fileDetails.group = groupName
                self.selectionModel.save()
            }
        default:
            break
        }
    }
    
    func tableView(tableView: NSTableView, sortDescriptorsDidChange oldDescriptors: [NSSortDescriptor]) {
        guard let sortDescriptor = tableView.sortDescriptors.first else {
            return
        }
        if let key = sortDescriptor.key{
            switch key {
            case "ImageName":
                self.filteredArrayOfFileInfos.sortInPlace(){
                    one, two in
                    if let oneFileName = one.fileURL?.lastPathComponent{
                        if let twoFileName = two.fileURL?.lastPathComponent{
                            if oneFileName < twoFileName  {
                                return sortDescriptor.ascending
                            }else{
                                return !sortDescriptor.ascending
                            }
                        }
                    }
                    return !sortDescriptor.ascending
                }
                
                print("Sort By Image Name ascending(\(sortDescriptor.ascending))")
                
            case "group":
                print("Sort By Group ascending(\(sortDescriptor.ascending)")
                
                self.filteredArrayOfFileInfos.sortInPlace(){
                    one, two in
                    if one.group < two.group  {
                        return sortDescriptor.ascending
                    }else{
                        return !sortDescriptor.ascending
                    }
                    return !sortDescriptor.ascending
                }

            default:
                break
            }
        }
    }
    
    
    
}

extension ViewController: NSTableViewDelegate{
    func tableViewSelectionDidChange(notification: NSNotification) {
        print("\(#function)")
        let selectedIndex = tableView.selectedRowIndexes.firstIndex
        if selectedIndex != NSNotFound{
            let selectedImgDetails = self.filteredArrayOfFileInfos[selectedIndex]
            updateViewWithInfo(selectedImgDetails)
        }else{
            imageView.image = nil
        }
        
    }
    
    func updateViewWithInfo(fileInfo:FileInformation){
        if let fileURL = fileInfo.fileURL, let image = NSImage(contentsOfURL: fileURL){
            imageView.imageScaling = .ScaleProportionallyUpOrDown
            imageView.image = image
        }
        if let fileURL = fileInfo.fileURL{
            fileDescriptionLabel.maximumNumberOfLines = 4
            fileDescriptionLabel.stringValue = fileURL.absoluteString
        }
    }
}
