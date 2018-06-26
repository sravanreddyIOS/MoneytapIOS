/*******************************************************************
 * © Copyright 2017. All Rights Reserved
 * Softtrends Software Private Limited.
 * Bangalore - 560038
 * India.
 *
 *
 * Project Name : nHance
 * File Name    : CacheDownloader.swift
 * Group        : iOS
 * Security     : Confidential
 *
 *
 * Created by Pradeep BM on 28/6/17.
 * Last Modified by Pradeep BM on 12/8/17.
 ********************************************************************/

import Foundation
import UIKit

typealias CacheDownloaderProgressBlock = (_ receivedSize: Int64, _ totalSize: Int64) -> ()
typealias CacheDownloaderCompleteBlock = (_ image: UIImage?, _ error: Error?, _ originData: Data?) -> ()

class CacheDownloader: NSObject {
    
    typealias callbackPair = (progressBlock: CacheDownloaderProgressBlock?, completeBlock: CacheDownloaderCompleteBlock?)
    
    class CacheFetchLoad {
        var callbacks = [callbackPair]()
        var responseData = Data()
    }
    
    var fetchLoads = [URL: CacheFetchLoad]()
    
    fileprivate let sessionHandler: CacheDownloaderSessionHandler
    
    fileprivate let session: URLSession?
    
    class func defaultDownloader() -> CacheDownloader {
        
        struct Static {
            static let instance = CacheDownloader()
        }
        return Static.instance
    }
    
    override init() {
        sessionHandler = CacheDownloaderSessionHandler()
        session = URLSession(configuration: URLSessionConfiguration.ephemeral, delegate: sessionHandler, delegateQueue: OperationQueue.main)
    }
    
    open func downloadImage(_ URL: URL,
                            progressBlock: CacheDownloaderProgressBlock?,
                            completeBlock: CacheDownloaderCompleteBlock?) -> Void {
        guard !URL.absoluteString.isEmpty else {return }
        
        setupAllCallbacks(URL, progressBlock: progressBlock, completeBlock: completeBlock)
        if let session = session {
            let dataTask = session.dataTask(with: URL)
            dataTask.resume()
            sessionHandler.downloader = self
        }
    }
    
    internal func setupAllCallbacks(_ URL: URL,
                                    progressBlock: CacheDownloaderProgressBlock?,
                                    completeBlock: CacheDownloaderCompleteBlock?) {
        
        let fetchLoad = self.fetchLoads[URL] ?? CacheFetchLoad()
        
        let callbackPair = (progressBlock: progressBlock, completeBlock: completeBlock)
        
        fetchLoad.callbacks.append(callbackPair)
        
        self.fetchLoads[URL] = fetchLoad
    }
}

class CacheDownloaderSessionHandler : NSObject, URLSessionDataDelegate {
    
    var downloader : CacheDownloader?
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        guard let downloader = downloader else {return }
        
        if let URL = dataTask.originalRequest?.url, let fetchLoad = downloader.fetchLoads[URL] {
            fetchLoad.responseData.append(data)
            
            for callback in fetchLoad.callbacks {
                callback.progressBlock?(Int64(fetchLoad.responseData.count), dataTask.response!.expectedContentLength)
            }
        }
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        guard let downloader = downloader else {return }
        
        if let URL = task.originalRequest?.url, let fetchLoad = downloader.fetchLoads[URL] {
            if let image = UIImage(data: fetchLoad.responseData as Data) {
                for callback in fetchLoad.callbacks {
                    callback.completeBlock?(image, nil, fetchLoad.responseData as Data)
                }
            }
        }
    }
    
}
