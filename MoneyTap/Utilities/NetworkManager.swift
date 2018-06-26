/*******************************************************************
 * © Copyright 2017. All Rights Reserved
 * Softtrends Software Private Limited.
 * Bangalore - 560038
 * India.
 *
 *
 * Project Name : nHance
 * File Name    : NetworkManager.swift
 * Group        : iOS
 * Security     : Confidential
 *
 *
 * Created by Pradeep BM on 27/02/17
 * Last Modified by Pradeep BM on 11/06/17.
 ********************************************************************/

import Foundation
import Alamofire

open class NHanceServerTrustPolicyManager: ServerTrustPolicyManager {
    
    // Override this function in order to trust any self-signed https
    open override func serverTrustPolicy(forHost host: String) -> ServerTrustPolicy? {
        return ServerTrustPolicy.disableEvaluation
        
        // or, if `host` contains substring, return `disableEvaluation`
        // Ex: host contains `my_company.com`, then trust it.
    }
}

//Network operations
class NetworkManager: NSObject {
    
    //Static members to do network operations
    static var defaultSessionManager: SessionManager!
    static var secureSessionManager: SessionManager!
    static var fileSessionManager: SessionManager!
    static var imageDownloadSessionManager: SessionManager!
    static var token : String?
    
    private static let reachability = Reachability.reachabilityForInternetConnection()
    class var sharedReachability: Reachability {
        return reachability
    }
    
    class var connectionError: ResponseError {
        
        let error = ResponseError(error: NetworkConstant.thErrorDomain, description: NSLocalizedString("ERROR_NO_INTERNET_CONNECTION",comment: ""), errorType: .noConnection)
        return error
    }
    
    class var authToken: String? {
        get {
            return token
        }
        set {
            if newValue != nil {
                //Session must be created with configuration else later modificaion of defaultHTTPHeaders will not have any effect
                //Secured manager
                
//                let serverTrustPolicies: [String: ServerTrustPolicy] = [
//                    URLBuilder.hostURL(): .disableEvaluation
//                ]
                
                let defaultHeaders = Alamofire.SessionManager.defaultHTTPHeaders
//                defaultHeaders[NetworkConstant.keyAuthTokenHeader] = newValue
                
                let configuration = URLSessionConfiguration.default
                configuration.httpAdditionalHeaders = defaultHeaders
                configuration.timeoutIntervalForRequest = 180
                configuration.requestCachePolicy = .reloadIgnoringCacheData
                self.secureSessionManager = Alamofire.SessionManager(configuration: configuration/*, serverTrustPolicyManager: ServerTrustPolicyManager(policies: serverTrustPolicies)*/)
                
                //fileSessionManager
                self.fileSessionManager = Alamofire.SessionManager(configuration: configuration/*, serverTrustPolicyManager: ServerTrustPolicyManager(policies: serverTrustPolicies)*/)
                
                //imageDownloadManager
                self.imageDownloadSessionManager = Alamofire.SessionManager(configuration: configuration/*, serverTrustPolicyManager: ServerTrustPolicyManager(policies: serverTrustPolicies)*/)
            }
        }
    }
    
    class func configureManager(authToken : String? = nil)
    {
//        let serverTrustPolicies: [String: ServerTrustPolicy] = [
//            URLBuilder.hostURL(): .disableEvaluation
//        ]
        
        var defaultHeaders = Alamofire.SessionManager.defaultHTTPHeaders
        defaultHeaders["Accept"] = "application/json"
        
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = defaultHeaders
        
        self.defaultSessionManager = Alamofire.SessionManager(configuration: configuration)
        //Alamofire.SessionManager(configuration: URLSessionConfiguration.default, serverTrustPolicyManager: ServerTrustPolicyManager(policies: serverTrustPolicies))
        self.authToken = authToken
    }
    
    class func cancelAllOperation()
    {
        self.defaultSessionManager.session.getTasksWithCompletionHandler
        {
            (dataTaskList, uploadTaskList, downloadTaskList) in
            
            dataTaskList.forEach { $0.cancel() }
            uploadTaskList.forEach { $0.cancel() }
            downloadTaskList.forEach { $0.cancel() }
        }
        
        self.secureSessionManager.session.getTasksWithCompletionHandler
        {
            (dataTaskList, uploadTaskList, downloadTaskList) in
            dataTaskList.forEach { $0.cancel() }
            uploadTaskList.forEach { $0.cancel() }
            downloadTaskList.forEach { $0.cancel() }
        }
        
        self.imageDownloadSessionManager.session.getTasksWithCompletionHandler { (dataTaskList, uploadTaskList, downloadTaskList) in
            dataTaskList.forEach { $0.cancel() }
            uploadTaskList.forEach { $0.cancel() }
            downloadTaskList.forEach { $0.cancel() }
        }
        
        self.fileSessionManager.session.getTasksWithCompletionHandler { (dataTaskList, uploadTaskList, downloadTaskList) in
            dataTaskList.forEach { $0.cancel() }
            uploadTaskList.forEach { $0.cancel() }
            downloadTaskList.forEach { $0.cancel() }
        }
    }
}


