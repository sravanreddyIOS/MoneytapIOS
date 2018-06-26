/*******************************************************************
 * © Copyright 2017. All Rights Reserved
 * Softtrends Software Private Limited.
 * Bangalore - 560038
 * India.
 *
 *
 * Project Name : nHance
 * File Name    : FileManager.swift
 * Group        : iOS
 * Security     : Confidential
 *
 *
 * Created by Pradeep BM on 27/02/17
 * Last Modified by Pradeep BM on 11/06/17.
 ********************************************************************/

import Foundation

//https://www.reddit.com/r/swift/comments/2c1gn2/how_to_do_optional_parameters_in_swift_protocols/
//http://stackoverflow.com/questions/34601931/is-it-possible-to-satisfy-swift-protocol-and-add-defaulted-arguments
//http://stackoverflow.com/questions/24041258/how-passing-a-protocol-as-parameter-in-swift
//https://gist.github.com/brunomacabeusbr/eea343bb9119b96eed3393e41dcda0c9


public typealias FileStatus = (isExist : Bool, isDirectory : Bool)

func isFileExistAt(path : String) -> FileStatus {
    return FileManager.default.isFileExistAt(path: path)
}

public enum FileType
{
    case ThumbnailFile , ContentFile , Database, TempFile, CacheFile, DicsussionFile, Test
    
    public func rootFilePath() -> URL {
        
        var result : URL
        
        switch self
        {
        case .ThumbnailFile, .ContentFile, .DicsussionFile, .Test:
            result = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).last!
            
        case .Database:
            result = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).last!
            
        case .CacheFile:
            let path = NSSearchPathForDirectoriesInDomains(.cachesDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).first!
            result = URL(string: path)!
            
        case .TempFile:
            result = URL(fileURLWithPath: NSTemporaryDirectory())
        }
        
        //Custom URL
        if let abosultePath = self.baseAbsoultePath(), abosultePath.characters.count > 0 {
            result = result.appendingPathComponent(abosultePath)
        }
        
        return result
    }
    
    func baseAbsoultePath() -> String? {
        var absoultePath = ""
        
        switch self
        {
        case .ThumbnailFile:
            absoultePath = "Resources/Thumbnail/"
            
        case .ContentFile:
            absoultePath = "Resources/ContentFile/"
            
        case .DicsussionFile:
            absoultePath = "Resources/Doubts/"
            
            
        case .Test:
            absoultePath = "Resources/Test/"
            
            
        default:
            break
        }
        return absoultePath
    }
    
    public func folder() -> URL?
    {
        //Base URL
        let result: URL = self.rootFilePath()
        
        //Creating folder if needed
        if !FileManager.default.fileExists(atPath: result.path)
        {
            do {
                try FileManager.default.createDirectory(at: result, withIntermediateDirectories: true, attributes: nil)
            } catch _ {
                return nil
            }
        }
        
        return result
    }
}

public protocol Filer
{
    func fileType() -> FileType
    func fileName() -> String
    func fileExtension() -> String
}

public extension FileManager
{
    public typealias Block = (_ url: URL?) -> Void
    public typealias BlockList = (_ url: [String]?) -> Void

    public static func uniqueURL(filer: Filer, _ block: @escaping Block)
    {
        startBackgroundTask()
        
        inTheBackground {
            if let result = filer.fileType().folder() {
                
                func uniqueId() -> String {
                    return "\(filer.fileName()).\(filer.fileExtension())"
                }
                
                let fileManager = FileManager.default
                var tempId = uniqueId()
                
                while fileManager.fileExists(atPath: result.appendingPathComponent(tempId).path)
                {
                    tempId = uniqueId()
                }
                
                onTheMainThread {
                    block(result.appendingPathComponent(tempId))
                    endBackgroundTask()
                }
                return
            }
            
            onTheMainThread {
                block(nil)
                endBackgroundTask()
            }
        }
    }
    
    public static func makeURL(filer: Filer, fileName: String, _ block: @escaping Block)
    {
        self.FormatURL(filer: filer, fileName: fileName, shouldExist: false, block: block)
    }
    
    public static func getURL(filer: Filer, fileName: String, _ block: @escaping Block)
    {
        self.FormatURL(filer: filer, fileName: fileName, shouldExist: true, block: block)
    }
    
    private static func FormatURL(filer: Filer, fileName: String, shouldExist: Bool, block: @escaping Block)
    {
        assert(fileName.characters.count > 2, "Invalid file name")
        
        startBackgroundTask()
        
        func end(url: URL?) {
            onTheMainThread {
                block(url)
                endBackgroundTask()
            }
        }
        
        inTheBackground {
            let fullFileName = "\(fileName).\(filer.fileExtension())"
            if let url = filer.fileType().folder()?.appendingPathComponent(fullFileName) {
                if shouldExist {
                    let fileManager = FileManager.default
                    if fileManager.fileExists(atPath: url.path) {
                        end(url: url)
                        return
                    }
                }
                end(url: url)
            }
        }
    }
    
    private static func createUrlPath(_ absoluteUrl : URL, fileName: String? = nil, shouldCreate: Bool = false, block: @escaping Block)
    {
        
        
        startBackgroundTask()
        
        func end(url: URL?) {
            onTheMainThread {
                block(url)
                endBackgroundTask()
            }
        }
        
        inTheBackground {
            
            var success = true
            
            var destinationUrl = absoluteUrl.deletingLastPathComponent()
            
            if shouldCreate {
                let fileManager = FileManager.default
                if !fileManager.fileExists(atPath: destinationUrl.path) {
                    do {
                        
                        try fileManager.createDirectory(at: destinationUrl, withIntermediateDirectories: true, attributes: nil)
                        
                    } catch {
                        success = false
                    }
                }
            }
            
            var finalFileName = ""
            if let fileName = fileName {
                
                finalFileName = fileName + ".\(absoluteUrl.pathExtension)"
                destinationUrl = absoluteUrl.appendingPathComponent(finalFileName)
            }else {
                finalFileName = absoluteUrl.lastPathComponent
                
                destinationUrl = destinationUrl.appendingPathComponent(finalFileName)
            }
            
            if success {
                end(url: destinationUrl)
            } else {
                end(url: nil)
            }
            
        }
    }
    
    public static func save(data: Data, forFiler filer: Filer, _ block: @escaping Block)
    {
        if data.count == 0 {
            block(nil)
            return
        }
        
        startBackgroundTask()
        
        func end(url: URL?) {
            onTheMainThread {
                block(url)
                endBackgroundTask()
            }
        }
        
        FileManager.uniqueURL(filer: filer) { (url) -> Void in
            if let finalURL = url {
                
                FileManager.save(data: data, toURL: finalURL) { (url) in
                    end(url: url)
                }
                return
            }
            end(url: nil)
        }
    }
    
    public static func save(data: Data, forFiler filer: Filer, withFileName fileName: String, overwrite: Bool, _ block: @escaping Block)
    {
        if data.count == 0 {
            block(nil)
            return
        }
        
        startBackgroundTask()
        
        func end(url: URL?) {
            onTheMainThread {
                block(url)
                endBackgroundTask()
            }
        }
        
        func proceed(finalURL: URL) {
            let fileManager = FileManager.default
            if fileManager.fileExists(atPath: finalURL.path) {
                if !overwrite {
                    end(url: nil)
                    return
                }
                FileManager.deleteFile(atURL : finalURL, { (url) -> Void in
                    
                    FileManager.save(data: data, toURL: finalURL) { (url) in
                        end(url: url)
                    }
                })
                return
            }
            
            FileManager.save(data: data, toURL: finalURL) { (url) in
                end(url: url)
            }
        }
        
        FileManager.makeURL(filer : filer, fileName: fileName) { (url) -> Void in
            if let finalURL = url {
                inTheBackground {
                    proceed(finalURL: finalURL)
                }
                return
            }
            end(url: nil)
        }
    }
    
    public static func saveBackground(data: Data, toURL: URL, shouldCreate: Bool = false, fileName: String? = nil, _ block: @escaping Block)
    {
        if data.count == 0 {
            block(nil)
            return
        }
        
        startBackgroundTask()
        
        func end(url: URL?) {
            onTheMainThread {
                block(url)
                endBackgroundTask()
            }
        }
        
        inTheBackground {
            FileManager.createUrlPath(toURL, fileName: fileName, shouldCreate: shouldCreate) { (destinationUrl) in
                if let resourceUrl =  destinationUrl {
                    FileManager.save(data: data, toURL: resourceUrl) { (url) in
                        end(url: url)
                    }
                    return
                }
                end(url: nil)
            }
        }
    }
    
    private static func save(data: Data, toURL: URL, _ block: @escaping Block)
    {
        inTheBackground {
            do {
                try data.write(to: toURL, options: .atomic)
                block(toURL)
            } catch  {
                print("Save resource data \(error)")
                block(nil)
            }
        }
    }
    
    public static func moveFile(fromURL: URL, toDestinationWithFileType fileType: FileType, _ block: @escaping Block)
    {
        startBackgroundTask()
        
        func end(url: URL?) {
            onTheMainThread {
                block(url)
                endBackgroundTask()
            }
        }
        
        inTheBackground {
            if !FileManager.default.fileExists(atPath: fromURL.path) {
                end(url: nil)
                return
            }
            
            func delete(finalURL: URL) {
                FileManager.deleteFile(atURL : fromURL, { (url) -> Void in
                    end(url: finalURL)
                })
            }
            
            func save(data: Data) {
                inTheBackground {
                    if let folder = fileType.folder() {
                        
                        FileManager.save(data: data, toURL: folder.appendingPathComponent(fromURL.lastPathComponent)) { (url) in
                            
                            if let finalURL = url {
                                delete(finalURL: finalURL)
                                return
                            }
                            end(url: nil)
                        }
                        
                        return
                    }
                    end(url: nil)
                }
            }
            
            do {
                let data = try Data(contentsOf: fromURL, options: .uncached)
                save(data: data)
            } catch _ {
                end(url: nil)
            }
        }
    }
    
    public static func deleteFile(atURL: URL, _ block: Block?)
    {
        let fileManager = FileManager.default
        startBackgroundTask()
        
        func end(url: URL?) {
            if let finalBlock = block {
                onTheMainThread {
                    finalBlock(url)
                }
            }
            endBackgroundTask()
        }
        
        inTheBackground {
            if !fileManager.fileExists(atPath: atURL.path) {
                end(url: nil)
                return
            }
            
            do {
                try fileManager.removeItem(at: atURL)
                end(url: atURL)
            } catch _ {
                end(url: nil)
            }
        }
    }
    
    public static func deleteFileLists(atURLString: [String], _ block: BlockList?)
    {
        let fileManager = FileManager.default
        startBackgroundTask()
        
        func end(url: [String]?) {
            if let finalBlock = block {
                onTheMainThread {
                    finalBlock(url)
                }
            }
            endBackgroundTask()
        }
        
        inTheBackground {
            
            for urlString in atURLString {
                if let url = URL(string: urlString) {
                    if !fileManager.fileExists(atPath: url.path) {
                        continue
                    }
                    
                    do {
                        try fileManager.removeItem(at: url)
                    } catch _ {
                        
                    }
                }
            }
            
            end(url: atURLString)
        }
    }
    
    public static func deleteAllFiles(type: FileType, _ block: Block?)
    {
        if let url = type.folder() {
            self.deleteFile(atURL : url, block)
        } else {
            if block != nil {
                onTheMainThread {
                    block?(nil)
                }
            }
        }
    }
    
    public func isFileExistAt(path pathString : String) -> FileStatus {
        
        var isDir : ObjCBool = true
        if self.fileExists(atPath: pathString, isDirectory:&isDir) {
            return (true, isDir.boolValue)
        } else {
            // file does not exist
            return (false, false)
        }
    }
    
    public static func deleteTempFiles(block: Block?)
    {
        FileManager.deleteAllFiles(type: .TempFile, block)
    }
    
    @discardableResult
    public static func excludeFileFromBackup(url: URL) -> Bool
    {
        var result: Bool
        do {
            
            var urlExclude = url
            var resourceValues = URLResourceValues()
            resourceValues.isExcludedFromBackup = true
            try urlExclude.setResourceValues(resourceValues)
            
            result = true
        } catch _ {
            result = false
        }
        
        return result
    }
}
