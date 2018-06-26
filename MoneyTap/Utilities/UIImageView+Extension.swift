/*******************************************************************
 * © Copyright 2017. All Rights Reserved
 * Softtrends Software Private Limited.
 * Bangalore - 560038
 * India.
 *
 *
 * Project Name : nHance
 * File Name    : UIImageView+Extension.swift
 * Group        : iOS
 * Security     : Confidential
 *
 *
 * Created by Pradeep BM on 08/03/17
 * Last Modified by Pradeep BM on 11/06/17.
 ********************************************************************/

import Foundation
import UIKit

extension UIImageView {
    
    func nh_setImageWithURL(_ path: URL, placeHolderImage: UIImage?, downloadNewly newly : Bool = NetworkManager.sharedReachability.isReachable() , completion : CacheDownloaderCompleteBlock?) {
        
        image = image ?? placeHolderImage
        
        if newly == true {
            self.downloadRemoteUrl(path, completion: completion)
        } else {
            let cache = CacheManager.defaultCache()
            
            cache.retriveImage(path) { (image, cacheType) in
                if let image = image {
                    self.image = image
                } else {
                    self.downloadRemoteUrl(path, completion: completion)
                }
            }
        }
    }
    
    func downloadRemoteUrl(_ path: URL, completion : CacheDownloaderCompleteBlock?) {
        
        let downloader = CacheDownloader.defaultDownloader()
        downloader.downloadImage(path, progressBlock: { (receivedSize, totalSize) in
            
            
        }) { (image, error, originData) in
            
            if let image = image {
                UIView.transition(with: self, duration: 1.0, options: UIViewAnimationOptions.transitionCrossDissolve, animations: {
                    self.image = image
                }, completion: { finished in
                    
                    CacheManager.defaultCache().storeImage(image, originData: originData, key: path, toDisk: true, complete: nil)
                    if let completionHandler = completion {
                        completionHandler(image, error, originData)
                    }
                })
            }
        }
    }
}
