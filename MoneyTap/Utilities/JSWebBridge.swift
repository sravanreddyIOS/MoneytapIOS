/*******************************************************************
 * © Copyright 2017. All Rights Reserved
 * Softtrends Software Private Limited.
 * Bangalore - 560038
 * India.
 *
 *
 * Project Name : nHance
 * File Name    : JSWebBridge.swift
 * Group        : iOS
 * Security     : Confidential
 *
 *
 * Created by Pradeep BM on 26/06/17
 * Last Modified by Pradeep BM on 11/06/17.
 ********************************************************************/

import Foundation
import WebKit

typealias JSWebBridgeHandle         = (_ name : String, _ result : Any?) -> Void
typealias JSWebViewRunJSHandler     = (_ completionHandler : JSWebBridgeResult) -> Void

public protocol JavaScriptResource  {
    var string : String? { get }
    var json:Dictionary<String, Any> { get }
}

extension String : JavaScriptResource {
    public var json: Dictionary<String, Any> {
        return [:]
    }
    public var string: String? { return self }
}

extension Dictionary : JavaScriptResource {
    public var string: String? { return "" }
    public var json: Dictionary<String, Any> {
        return  ["params":self]
    }
}

//MARK:- JSWebBridgeResult
//Custom java script response
class JSWebBridgeResult {
    
    var result : Any?
    var error : Error?
    var errroMsg : String?
    var errorCode : Int?
    
    required init(response result :Any?, error dataError : Error?) {
        self.result         = result
        self.error          = dataError
        self.errroMsg       = self.error?.localizedDescription
        self.errorCode      = self.error?._code
    }
}

//MARK:- JSWebBridge
class JSWebBridge : NSObject {
    
    var wkConfiguretion : WKWebViewConfiguration? {
        didSet {
            wkConfiguretion!.preferences            = WKPreferences()
            wkConfiguretion!.processPool            = WKProcessPool()
            wkConfiguretion!.userContentController  = WKUserContentController()
            wkConfiguretion!.preferences.javaScriptCanOpenWindowsAutomatically = false
        }
    }
    var webView : WKWebView?
    var webHandleCache = [String : JSWebBridgeHandle]()
    
    convenience init(webView : WKWebView) {
        self.init()
        self.webView            = webView
        self.wkConfiguretion    = self.webView?.configuration
    }
}

//MARK:- Helper Methods
extension JSWebBridge {
    
    func registerHandler(_ name : String?, handle : JSWebBridgeHandle?) {
        
        guard name != nil else {
            return
        }
        
        self.webView?.configuration.userContentController.add(self, name: name!)
        guard handle != nil else {
            return
        }
        
        self.webHandleCache[name!] = handle
    }
    
    func runJavaScript(_ msg : String , completionHandler : JSWebViewRunJSHandler?) {
        self.runJavaScript(msg, data: nil, completionHandler: completionHandler)
    }
    
    func runJavaScript(_ msg : String, data : JavaScriptResource?, completionHandler : JSWebViewRunJSHandler?) {
        
        var javaScript  : String    = msg
        let dict                    = data?.json["params"]
        
        if dict != nil {
            if let data = try? JSONSerialization.data(withJSONObject: (dict)!, options: []),
                let string = String(data: data, encoding: String.Encoding.utf8) {
                javaScript = String(format: "%@(%@);", msg,string)
            }
            
        } else if data?.string != nil {
            
            javaScript = String(format: "%@(%@);", msg,(data?.string)!)
        }
        
        print("message sending JS is",javaScript)
        
        self.webView?.evaluateJavaScript(javaScript, completionHandler: { (result, error) in
            completionHandler?(JSWebBridgeResult(response: result ,error: error))
        })
    }
}

//MARK:- WKScriptMessageHandler
extension JSWebBridge : WKScriptMessageHandler {
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        
        let handle = self.webHandleCache[message.name]
        if handle != nil {
            handle!(message.name , message.body)
        }
    }
}

//MARK:- Class Methods
extension JSWebBridge {
    
    class func bridgeForWebView(_ webView : WKWebView) -> JSWebBridge {
        let bridge = JSWebBridge(webView: webView)
        return bridge
    }
}
