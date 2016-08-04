//
//  ViewController.swift
//  PictureSelector
//
//  Created by Robert on 04/08/16.
//  Copyright © 2016 IBM. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    var selectionModel: SelectionModel?{
        didSet{
            self.refreshLocalModel()
        }
    }
    
    var filteredArrayOfFileInfos:[FileInformation] = [FileInformation](){
        didSet{
        }
    }
    func refreshLocalModel(){
        if let selectionModel = self.selectionModel{
            
            self.filteredArrayOfFileInfos.removeAll()
            
            for imgInfo in selectionModel.imageInformationArray{
                switch self.currentlySelectedShowOption {
                case .All:
                    self.filteredArrayOfFileInfos.append(imgInfo)
                case .NonSelected:
                    if imgInfo.selected == false{
                        self.filteredArrayOfFileInfos.append(imgInfo)
                    }
                case .Selected:
                    if imgInfo.selected{
                        self.filteredArrayOfFileInfos.append(imgInfo)
                    }
                }
            }
            
            self.filteredArrayOfFileInfos.sortInPlace(){
                one, two in
                if let oneStringProperty = self.currentSortingMetho.stringPropertyToSort(one) {
                    if let twoStringProperty = self.currentSortingMetho.stringPropertyToSort(two){
                        if oneStringProperty < twoStringProperty  {
                            return self.currentSortingMetho.ascendingBoolValue
                        }else{
                            return !self.currentSortingMetho.ascendingBoolValue
                        }
                    }
                }
                return !self.currentSortingMetho.ascendingBoolValue
            }
            
            self.tableView.reloadData()
        }
    }
    
    @IBOutlet weak var fileDescriptionLabel: NSTextField!
    @IBOutlet weak var tableView: NSTableView!
    
    @IBOutlet weak var imageView: NSImageView!
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.setDataSource(self)
        tableView.setDelegate(self)

        self.initializeShowOptions()
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
    
    //MARK:- Show options
    
    var currentlySelectedShowOption:ShowOptions = .All{
        didSet{
            allCheckBox.state = NSNumber.init(bool:(currentlySelectedShowOption == .All)).integerValue
            selectedCheckBox.state = NSNumber.init(bool:(currentlySelectedShowOption == .Selected)).integerValue
            nonSelectedCheckbox.state = NSNumber.init(bool:(currentlySelectedShowOption == .NonSelected)).integerValue
            
            self.refreshLocalModel()
        }
    }
    
    @IBOutlet weak var allCheckBox: NSButton!
    @IBOutlet weak var nonSelectedCheckbox: NSButton!
    @IBOutlet weak var selectedCheckBox: NSButton!
    
    enum ShowOptions: Int { case All = 10, Selected = 20, NonSelected = 30 }
    
    var showSelected = true{
        didSet{
            self.refreshLocalModel()
        }
    }
    var showNonSelected = true{
        didSet{
            self.refreshLocalModel()
        }
    }
    
    func initializeShowOptions(){
        allCheckBox.tag = ShowOptions.All.rawValue
        selectedCheckBox.tag = ShowOptions.Selected.rawValue
        nonSelectedCheckbox.tag = ShowOptions.NonSelected.rawValue
        self.currentlySelectedShowOption = .All
    }
    
    @IBAction func showOptionChanged(sender: NSButton) {
        if let showOption = ShowOptions(rawValue: sender.tag){
            currentlySelectedShowOption = showOption
        }
    }
    
    //MARK:- outlets and Actions

    @IBAction func selectFolderButtonClicked(sender: AnyObject) {
        self.initializeBasics()
    }

    
    @IBAction func saveButtonClicked(sender: NSButton) {
        if let selectionModel = self.selectionModel{
            let pasteboard = NSPasteboard.generalPasteboard()
            pasteboard.declareTypes([NSPasteboardTypeString], owner: nil)
            pasteboard.setString(selectionModel.selectedFilesInText(), forType: NSPasteboardTypeString)
        }
    }
    
    // MARK:- Sorting
    
    var currentSortingMetho: SortingOfTableView = .ImageName(ascending:true){
        didSet{
            self.refreshLocalModel()
        }
    }
    enum SortingOfTableView {
        case ImageName(ascending:Bool), Group(ascending:Bool)
        func stringPropertyToSort(imageInfo: FileInformation) -> String?{
            switch self {
            case .ImageName:
                return imageInfo.fileURL?.lastPathComponent
            default:
                return imageInfo.group
            }
        }
        var ascendingBoolValue: Bool{
            switch self{
            case .Group(let ascending):
                    return ascending
            case .ImageName(let ascending):
                    return ascending
            }
        }
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
                self.selectionModel?.save()
            }
        case "group":
            if let groupName = object as? String{
                fileDetails.group = groupName
                self.selectionModel?.save()
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
                print("Sort By Image Name ascending(\(sortDescriptor.ascending))")
                self.currentSortingMetho = .ImageName(ascending:sortDescriptor.ascending)
                
            case "group":
                print("Sort By Group ascending(\(sortDescriptor.ascending)")
                self.currentSortingMetho = .Group(ascending:sortDescriptor.ascending)

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
