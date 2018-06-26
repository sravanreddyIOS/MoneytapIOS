/*******************************************************************
 * © Copyright 2017. All Rights Reserved
 * Softtrends Software Private Limited.
 * Bangalore - 560038
 * India.
 *
 *
 * Project Name : nHance
 * File Name    : ResponseError.swift
 * Group        : iOS
 * Security     : Confidential
 *
 *
 * Created by Pradeep BM on 28/02/17.
 * Last Modified by Pradeep BM on 21/03/17.
 ********************************************************************/

import Foundation

public enum ErrorType: String {
    case noConnection = "NoConnection Error"
    case objectNotFound = "ObjectNotFound Error"
    case noCategoryListExist = "noCategoryListExist"
    case useNotExistInOrg = "useNotExistInOrg"
    case userBlockedInOrg = "userBlockedInOrg"
    case serverError = "Server Error"
    case uplaodError = "Upload Error"
    case fileMaskError = "Mask Error"
}

enum ErrorCode : String {
    case missingParameter = "MISSING_PARAMETERS"
    case invalidDataFormat = "INVALID_DATE_FORMAT"
    case userAlreadyExist = "USER_ALREADY_EXISTS"
    case alreadyLoggedIn = "ALREADY_LOGGED_IN"
    case alreadyLoggedOut = "ALREADY_LOGGED_OUT"
    case serviceError = "SERVICE_ERROR"
    case organizationNotFound = "ORGANIZATION_NOT_FOUND"
    case contentNotVisible = "CONTENT_NOT_VISIBLE"
    case organizationNotSupported = "ORG_SIGNUP_NOT_SUPPORTED" /*Org SignUp Not supported*/
    case testNotAttempted   = "NOT_ATTEMPTED"
    case testMultiAttemptNotAllowed = "MULTI_ATTEMPTS_NOT_ALLOWED"
    case alreadyFollowingContent = "ALREADY_FOLLOWING" /*If your following same id*/
    case notFollowingContent = "NOT_FOLLOWING" /*If your trying unfollowing content which is not following*/
    case none = "None"
}

class ResponseError: Error {
    
    open var errorCode: ErrorCode? = .none
    
    open var localizedDescription: String = ""
    
    open var errorType: ErrorType = .noConnection
    
    open var request: URLRequest?
    
    open var JSON: Any?
    
    open var statusCode: Int = 0
    
    public init(error: String, description: String = "", errorType: ErrorType = .serverError) {
        self.errorCode = ErrorCode(rawValue: error) ?? .none
        
        let errorDescription = description.isEmpty ? NSLocalizedString(error, comment: "") : description
        
        self.localizedDescription = errorDescription.replacingOccurrences(of: "_", with: " ").capitalized
        self.errorType = errorType
    }
    
    open var description: String {
        return String(format: "%@: \((errorCode?.rawValue ?? "")) Description: %@ status \(statusCode)", errorType.rawValue, localizedDescription)
    }
    
}
