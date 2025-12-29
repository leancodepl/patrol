//
//  NavWebView.swift
//  Sample iOS
//
//  Created by Lalit on 21/01/18.
//  Copyright © 2018 BrowserStack. All rights reserved.
//

import UIKit
import WebKit

class NavWebView: UIViewController, WKUIDelegate {

    
    @IBOutlet weak var webview: WKWebView!
    
    
    
    override func loadView() {
        let webConfiguration = WKWebViewConfiguration()
        webview = WKWebView(frame: .zero, configuration: webConfiguration)
        webview.uiDelegate = self
        view = webview
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let url = URL(string:"https://www.browserstack.com")
        let request = URLRequest(url: url!)
        
        webview.load(request)
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }


}

