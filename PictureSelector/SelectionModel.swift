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
    
    
    //MARK:- Selection to & fro Dictionary
    var fileNameToSave = "selectedList.plist"
    func save(){
        
        var arrayOfFiles = [String]()
        
        for imgInfo in imageInformationArray{
            if let filePath = imgInfo.filePath where imgInfo.selected, let fileName = filePath.lastPathComponent{
                arrayOfFiles.append(fileName)
            }
        }
        
        do {
            let data = try NSPropertyListSerialization.dataWithPropertyList(arrayOfFiles, format: .XMLFormat_v1_0, options:0)
            if let folderPath = folderPath{
                let fileURL = folderPath.URLByAppendingPathComponent(fileNameToSave)
                try data.writeToURL(fileURL, options: .DataWritingAtomic)
            }
        }catch let error{
            print("error: \(error)")
        }
        
    }
    
    
    func isFileSelected(fileURL:NSURL) -> Bool{
        if let pathComponent = fileURL.lastPathComponent{
            if selectedFileNames.contains(pathComponent){
                return true
            }
        }
        return false
    }
    
    var selectedFileNames = [String]()
    
    func initialzeFilesSelected(){
        selectedFileNames.removeAll()
        if let folderPath = folderPath{
            let fileURL = folderPath.URLByAppendingPathComponent(fileNameToSave)
            if let data = NSData(contentsOfURL: fileURL){
                do{
                    let propertyListObject = try NSPropertyListSerialization.propertyListWithData(data, options: NSPropertyListReadOptions(), format: nil)
                    if let propertyListObjectArray = propertyListObject as? [String]{
                        selectedFileNames.appendContentsOf(propertyListObjectArray)
                    }
                }catch let error{
                    print("error: \(error)")
                }
            }
        }
    }
    
}