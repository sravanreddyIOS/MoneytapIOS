/*******************************************************************
 * © Copyright 2017. All Rights Reserved
 * Softtrends Software Private Limited.
 * Bangalore - 560038
 * India.
 *
 *
 * Project Name : nHance
 * File Name    : CloudDocument.swift
 * Group        : iOS
 * Security     : Confidential
 *
 *
 * Created by Pradeep BM on 22/06/17
 * Last Modified by Pradeep BM on 11/06/17.
 ********************************************************************/

import Foundation
import UIKit

enum DocumentReadError: Error {
    case InvalidInput
}

enum DocumentWriteError: Error {
    case NoContentToSave
}

class CloudDocument: UIDocument {
    
    var documentContents:String?
    
    override init(fileURL url: URL) {
        super.init(fileURL: url)
    }
    
    override func load(fromContents contents: Any, ofType typeName: String?) throws {
        if let castedContents = contents as? Data {
            documentContents = String(data: castedContents, encoding: String.Encoding.utf8)
        } else {
            documentContents = nil
            throw DocumentReadError.InvalidInput
        }
    }
    
    override func contents(forType typeName: String) throws -> Any {
        if documentContents == nil {
            throw DocumentWriteError.NoContentToSave
        } 
        return 	documentContents!.data(using: String.Encoding.utf8)! 
    } 
}
