//
//  ViewController.swift
//  MoneyTap
//
//  Created by GADEVAPPLE on 25/06/18.
//  Copyright © 2018 GADEVAPPLE. All rights reserved.
//

import UIKit
import WebKit

class WikipediaController: UIViewController,UIWebViewDelegate,WKNavigationDelegate
{

    @IBOutlet weak var webview: WKWebView!
    var Tittle : String?
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var forwardButton: UIButton!

    override func viewDidLoad()
    {
        if Tittle?.isEmpty == false
        {
            webview.navigationDelegate = self
            indicator.startAnimating()
            indicator.hidesWhenStopped = true
            indicator.color = UIColor(rgba: "FF8C00")
            let text = Tittle?.replacingOccurrences(of: " ", with: "_")
            webview.load(URLRequest(url: URL(string: "https://en.wikipedia.org/wiki/\(text!))")! ))
            
            webview.scrollView.bounces = true
            let refreshControl = UIRefreshControl()
            refreshControl.addTarget(self, action: #selector(WikipediaController.refreshWebView), for: UIControlEvents.valueChanged)
            webview.scrollView.addSubview(refreshControl)

        }

        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        indicator.stopAnimating()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        indicator.stopAnimating()
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        indicator.startAnimating()
    }
    
    @objc func refreshWebView(sender: UIRefreshControl) {
        print("refersh")
        //
        sender.endRefreshing()
    }
    
    //back button
    @IBAction func backButtonTapped(_ sender: Any)
    {
        if webview.canGoBack {
            webview.goBack()
        }
    }
    
    @IBAction func forwardButtonTapped(_ sender: Any) {
        if webview.canGoForward {
            webview.goForward()
        }
    }
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!)
    {
        backButton.isEnabled = webView.canGoBack
        forwardButton.isEnabled = webView.canGoForward
    }

}

