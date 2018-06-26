/*******************************************************************
 * © Copyright 2017. All Rights Reserved
 * Softtrends Software Private Limited.
 * Bangalore - 560038
 * India.
 *
 *
 * Project Name : nHance
 * File Name    : Alamofire+DataRequest.swift
 * Group        : iOS
 * Security     : Confidential
 *
 *
 * Created by Pradeep BM on 28/02/17
 * Last Modified by Pradeep BM on 11/06/17.
 ********************************************************************/

import Foundation
import Alamofire

typealias ResponseCompletionHandler = ((ResponseData) -> Void)

extension DataRequest
{
    
    func generateResponseSerialization(serialization : JSONSerialization.ReadingOptions = .allowFragments, completion : ResponseCompletionHandler?) {
        
        responseJSON(options: serialization) { (DataResponse) in
            let resp = formatURLResponse(DataResponse.request, response: DataResponse.response, JSON: DataResponse.result.value, error: DataResponse.result.error)
            completion?(resp)
        }
        
    }
}

func formatURLResponse(_ request: URLRequest?, response: HTTPURLResponse?, JSON: Any?, error: Error?) -> ResponseData {
    
    let _response = ResponseData(URLRequest: request, response: response)
    
    if let status = response?.statusCode {
        
        _response.statusCode = status
        
        switch status {
        case 200...300 :
            _response.JSON = JSON
            if let jsonResponse = JSON as? [String: AnyObject] {
                _response.JSON = jsonResponse
            }
            
            if let jsonResponse = JSON as? [String: AnyObject] {
                let errorCode = jsonResponse["errorCode"] as? String
                if errorCode?.isEmpty == false {
                    _response.error = getError(JSON)
                    _response.error?.statusCode = status
                }
            }
            return _response
            
        case 400, 404, 500, 502, 401, 403:
            _response.error = getError(JSON)
            _response.error?.statusCode = status
            return _response
        default:
            break
        }
    }
    
    if let _nsError = error {
        _response.error = ResponseError(
            error: _nsError.localizedDescription,
            description: _nsError.localizedDescription
        )
    } else if _response.error == nil {
        _response.error = ResponseError(
            error: NetworkConstant.ParserError,
            description: "Unknown status \(response?.statusCode ?? 0)"
        )
    }
    
    _response.error?.statusCode = response?.statusCode ?? 0
    
    return _response
}

func getError(_ json: Any?) -> ResponseError? {
    
    var error = "", errorDescription = ""
    
    if let json = json as? [String: Any] {
        if let rawError = json["error"] as? String {
            error = rawError
        } else if let rawErrorCode = json["errorCode"] as? String {
            error = rawErrorCode
        }
        
        if let rawErrorDescription = json["errorDescription"] as? String {
            errorDescription = rawErrorDescription
        } else if let rawErrorMessage = json["errorMessage"] as? String {
            errorDescription = rawErrorMessage
        }
    }
    
    let e = ResponseError(error: error, description: errorDescription)
    e.JSON = json
    
    return e
}

