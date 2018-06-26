/*******************************************************************
 * © Copyright 2017. All Rights Reserved
 * Softtrends Software Private Limited.
 * Bangalore - 560038
 * India.
 *
 *
 * Project Name : nHance
 * File Name    : ResponseData.swift
 * Group        : iOS
 * Security     : Confidential
 *
 *
 * Created by Pradeep BM on 08/02/17.
 * Last Modified by Pradeep BM on 14/03/17.
 ********************************************************************/

import Foundation

class ResponseData : NSObject {
    
    open var URLRequest: URLRequest?
    
    open var URLResponse: URLResponse?
    
    open var JSON: Any?
    
    open var error: ResponseError?
    
    open var statusCode: Int = 0
    
    open var success: Bool {
        return error == nil && (200...299 ~= statusCode)
    }
    
    public init(URLRequest: URLRequest?, response: URLResponse?) {
        super.init()
        
        self.URLRequest = URLRequest
        self.URLResponse = response
    }
    
    open var logDescription: String {
        return String(format: "Server Response \(String(describing: JSON)) with error \(String(describing: error?.description))")
    }
}
