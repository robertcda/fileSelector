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
    
    private var folderPath:NSURL?
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
    
}