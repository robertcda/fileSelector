//
//  SelectionModel.swift
//  PictureSelector
//
//  Created by Robert on 04/08/16.
//  Copyright © 2016 IBM. All rights reserved.
//

import Foundation

class FileInformation{
    var filePath:NSURL?
    var selected:Bool = false
    var group: String = ""
}

class SelectionModel{
    
    var imageInformationArray = [FileInformation]()
    
    private var folderPath:NSURL?{
        didSet{
        }
    }
    
    private var arrayOfFileURLs = [NSURL](){
        didSet{
            imageInformationArray.removeAll()
            for imgURL in arrayOfFileURLs{
                if let path = imgURL.pathExtension{
                    switch path{
                    case "JPG": fallthrough
                    case "BMP": fallthrough
                    case "PNG":
                        
                        let fileInfoObject = FileInformation()
                        fileInfoObject.filePath = imgURL
                        fileInfoObject.selected = isFileSelected(imgURL)
                        fileInfoObject.group = groupOfFile(imgURL)
                        self.imageInformationArray.append(fileInfoObject)
                        
                    default:
                        continue
                    }
                }
            }
        }
    }
    
    init(fromFolderPath folderPath: NSURL){
        self.folderPath = folderPath
        self.initialzeFilesSelected()
        self.parseAllFilesInFolderPath()
    }
    
    func parseAllFilesInFolderPath(){
        do{
            arrayOfFileURLs.removeAll()
            if let folderPath = folderPath{
                let arrayOfFiles = try NSFileManager.defaultManager().contentsOfDirectoryAtURL(folderPath, includingPropertiesForKeys: nil, options:NSDirectoryEnumerationOptions())
                print("arrayOfFiles:\(arrayOfFiles)")
                arrayOfFileURLs.appendContentsOf(arrayOfFiles)
            }
        }catch let error{
            print("parseAllFilesInFolderPath: error:\(error)")
        }
    }
    
    // MARK:- Interface to get the selected files in text format.
    func selectedFilesInText() -> String{
        var selectedText: String = ""
        
        var allGroupsInformation = [String:[String]]()
        
        for (fileName,group) in selectedFileDetails{
            if let array = allGroupsInformation[group]{
                
                var mutArray = [String]()
                mutArray.appendContentsOf(array)
                mutArray.append(fileName)
                
                allGroupsInformation[group] = mutArray
            }else{
                allGroupsInformation[group] = [fileName]
            }
        }
        
        for (groupName,arrayOfFiles) in allGroupsInformation{
            selectedText += groupName
            selectedText += ":\n"
            for imgName in arrayOfFiles{
                selectedText += imgName
                selectedText += ", "
            }
            selectedText += "\n\n"
            selectedText += "--------\n"
        }
        
        return selectedText
    }
    
    //MARK:- Selection to & fro Dictionary
    var fileNameToSave = "selectedList.plist"
    func save(){
        
        var dictionaryOfFileDetails = [String:String]()
        
        for imgInfo in imageInformationArray{
            if let filePath = imgInfo.filePath where imgInfo.selected, let fileName = filePath.lastPathComponent{
                dictionaryOfFileDetails[fileName] = imgInfo.group ?? ""
            }
        }
        
        do {
            let data = try NSPropertyListSerialization.dataWithPropertyList(dictionaryOfFileDetails, format: .XMLFormat_v1_0, options:0)
            if let folderPath = folderPath{
                let fileURL = folderPath.URLByAppendingPathComponent(fileNameToSave)
                try data.writeToURL(fileURL, options: .DataWritingAtomic)
            }
        }catch let error{
            print("error: \(error)")
        }
        
        self.initialzeFilesSelected()
    }
    
    func groupOfFile(fileURL:NSURL) -> String{
        if let pathComponent = fileURL.lastPathComponent{
            for (fileName,group) in selectedFileDetails{
                if fileName == pathComponent{
                    return group
                }
            }
        }
        return ""
    }

    
    func isFileSelected(fileURL:NSURL) -> Bool{
        if let pathComponent = fileURL.lastPathComponent{
            for (fileName,_) in selectedFileDetails{
                if fileName == pathComponent{
                    return true
                }
            }
        }
        return false
    }
    
    var selectedFileDetails = [String:String]()
    
    func initialzeFilesSelected(){
        selectedFileDetails.removeAll()
        if let folderPath = folderPath{
            let fileURL = folderPath.URLByAppendingPathComponent(fileNameToSave)
            if let data = NSData(contentsOfURL: fileURL){
                do{
                    let propertyListObject = try NSPropertyListSerialization.propertyListWithData(data, options: NSPropertyListReadOptions(), format: nil)
                    if let propertyListObjectDictionary = propertyListObject as? [String:String]{
                        selectedFileDetails = selectedFileDetails.mergedWith(propertyListObjectDictionary)
                    }
                }catch let error{
                    print("error: \(error)")
                }
            }
        }
    }
    
}

extension Dictionary {
    func mergedWith(otherDictionary: [Key: Value]) -> [Key: Value] {
        var mergedDict: [Key: Value] = [:]
        [self, otherDictionary].forEach { dict in
            for (key, value) in dict {
                mergedDict[key] = value
            }
        }
        return mergedDict
    }
}
