/*******************************************************************
 * © Copyright 2017. All Rights Reserved
 * Softtrends Software Private Limited.
 * Bangalore - 560038
 * India.
 *
 *
 * Project Name : nHance
 * File Name    : JsonParser.swift
 * Group        : iOS
 * Security     : Confidential
 *
 *
 * Created by Pradeep BM on 07/03/17
 * Last Modified by Pradeep BM on 11/06/17.
 ********************************************************************/

import Foundation

public enum JsonParser {
    
    case Array([AnyObject])
    case Dictionary([String: AnyObject])
    case String(String)
    case Number(Float)
    case Null
    
    public var string: String? {
        switch self {
        case .String(let s):
            return s
        default:
            return nil
        }
    }
    
    public var int: Int? {
        switch self {
        case .Number(let d):
            return Int(d)
        default:
            return nil
        }
    }
    
    public var float: Float? {
        switch self {
        case .Number(let d):
            return d
        default:
            return nil
        }
    }
    
    public var bool: Bool? {
        switch self {
        case .Number(let d):
            return (d != 0)
        default:
            return nil
        }
    }
    
    public var isNull: Bool {
        switch self {
        case .Null:
            return true
        default:
            return false
        }
    }
    
    public var dictionary: [String: JsonParser]? {
        switch self {
        case .Dictionary(let d):
            var jsonObject: [String: JsonParser] = [:]
            for (k,v) in d {
                jsonObject[k] = JsonParser.wrap(json: v)
            }
            return jsonObject
        default:
            return nil
        }
    }
    
    public var array: [JsonParser]? {
        switch self {
        case .Array(let array):
            let jsonArray = array.map({ JsonParser.wrap(json: $0) })
            return jsonArray
        default:
            return nil
        }
    }
}

//MARK:- Static method type
extension JsonParser {
    
    public static func wrap(json: AnyObject) -> JsonParser {
        if let str = json as? String {
            return .String(str)
        }
        if let num = json as? NSNumber {
            return .Number(num.floatValue)
        }
        if let dictionary = json as? [String: AnyObject] {
            return .Dictionary(dictionary)
        }
        if let array = json as? [AnyObject] {
            return .Array(array)
        }
        return .Null
    }
    
    public static func parse(data: Data) -> JsonParser? {
        do {
            let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
            return wrap(json: json as AnyObject)
        } catch  _ {
            return nil
        }
    }
}

//MARK:- Subscript
extension JsonParser {
    
    public subscript(index: String) -> JsonParser? {
        switch self {
        case .Dictionary(let dictionary):
            if let value: AnyObject = dictionary[index] {
                return JsonParser.wrap(json: value)
            }
            fallthrough
        default:
            return nil
        }
    }
    
    public subscript(index: Int) -> JsonParser? {
        switch self {
        case .Array(let array):
            return JsonParser.wrap(json: array[index])
        default:
            return nil
        }
    }
}
