/*******************************************************************
 * © Copyright 2017. All Rights Reserved
 * Softtrends Software Private Limited.
 * Bangalore - 560038
 * India.
 *
 *
 * Project Name : nHance
 * File Name    : CacheManager.swift
 * Group        : iOS
 * Security     : Confidential
 *
 *
 * Created by Pradeep BM on 28/6/17.
 * Last Modified by Pradeep BM on 12/8/17.
 ********************************************************************/

import Foundation
import UIKit

enum CacheType : Int {
    case memory
    case disk
    case noneType
}

class CacheManager : NSObject {
    
    // Memory
    fileprivate let memoryCache = NSCache<AnyObject, AnyObject>()
    
    // Disk
    fileprivate let fileManager = FileManager.default
    fileprivate let ioQueue: GCDQueue
    fileprivate let diskCachePath: String
    
    class func defaultCache() -> CacheManager {
        struct Static {
            static let instance = CacheManager(cacheName: "imageCache")
        }
        return Static.instance
    }
    
    init(cacheName: String) {
        
        self.memoryCache.name = cacheName
        
        self.diskCachePath = FileType.CacheFile.rootFilePath().absoluteString
        
        self.ioQueue = GCDQueue(serial: "CacheManagerQueue")
    }
}


// MARK: Retrive Image Data
extension CacheManager {
    
    public func retriveImage(_ key: URL, completionHandler:((UIImage?, CacheType) -> Void)?) {
        guard let completionHandler = completionHandler else { return }
        
        if let image = self.retriveImageFromMemory(key) {
            
            DispatchQueue.main.async(execute: {
                completionHandler(image, .memory)
            })
        } else {
            
            GCD.async(.custom(self.ioQueue), closure: {
                if let image = self.retriveImageFromDisk(key) {
                    self.storeImage(image, originData: nil, key: key, toDisk: false, complete: nil)
                    DispatchQueue.main.async(execute: {
                        completionHandler(image, .disk)
                    })
                } else {
                    DispatchQueue.main.async(execute: {
                        completionHandler(nil, .noneType)
                    })
                }
            })
        }
    }
    
    public func retriveImageFromMemory(_ key: URL) -> UIImage? {
        return self.memoryCache.object(forKey: key.absoluteString as AnyObject) as? UIImage
    }
    
    public func retriveImageFromDisk(_ key: URL) -> UIImage? {
        
        let lastPath = key.lastPathComponent
        
        let finalFilePath = lastPath
        
        let filePath = self.diskCachePath.appending(finalFilePath)//(diskCachePath as NSString).appending(key)
        if let data = try? Data(contentsOf: URL(fileURLWithPath: filePath)) {
            return UIImage(data: data)
        }
        return nil
    }
}

// MARK: Store&Remove
extension CacheManager {
    
    public func storeImage(_ image: UIImage, originData: Data? = nil, key: URL, toDisk: Bool, complete:(() -> Void)?) {
        self.memoryCache.setObject(image, forKey: key.absoluteString as AnyObject)
        
        func callHandlerInMainQueue() {
            if let handler = complete {
                DispatchQueue.main.async(execute: {
                    handler()
                })
            }
        }
        
        if toDisk {
            
            GCD.async(.custom(self.ioQueue), closure: {
                
                let data: Data?
                if let originData = originData {
                    data = originData
                } else {
                    data = UIImagePNGRepresentation(image)
                }
                
                if let data = data {
                    if !self.fileManager.fileExists(atPath: self.diskCachePath) {
                        do {
                            try self.fileManager.createDirectory(atPath: self.diskCachePath, withIntermediateDirectories: true, attributes: nil)
                        } catch {
                            print("cache disk file creation error \(error)")
                        }
                    }
                    
                    let lastPath = key.lastPathComponent
                    
                    let finalFilePath = lastPath
                    
                    let filePath = self.diskCachePath.appending(finalFilePath)//(self.diskCachePath as NSString).appending(key)
                    self.fileManager.createFile(atPath: filePath, contents: data, attributes: nil)
                }
                callHandlerInMainQueue()
            })
            
        } else {
            callHandlerInMainQueue()
        }
    }
    
    public func removeImageForKey(_ key: String, fromDisk: Bool, complete:(() -> Void)?) {
        self.memoryCache.removeObject(forKey: key as AnyObject)
        
        func callHandlerInMainQueue() {
            if let handler = complete {
                DispatchQueue.main.async(execute: {
                    handler()
                })
            }
        }
        
        if fromDisk {
            
            GCD.async(.custom(self.ioQueue), closure: {
                do {
                    let path = self.diskCachePath.appending(key)
                    try self.fileManager.removeItem(atPath: path)
                } catch _ {}
                callHandlerInMainQueue()
            })
            
        } else {
            callHandlerInMainQueue()
        }
    }
}
