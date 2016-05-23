//
//  ViewController.swift
//  BB1024
//
//  Created by 林满佳 on 16/3/27.
//  Copyright © 2016年 林满佳. All rights reserved.
//

import UIKit
import WebKit
import Cartography

class ViewController: UIViewController, WKScriptMessageHandler {
    
    var webview: WKWebView?
    var magnet: String?
    
    @IBAction func openuri(sender: AnyObject) {
        UIApplication.sharedApplication().openURL(NSURL(string: "oof.disk://lx/" + magnet!)!)
        UIPasteboard.generalPasteboard().string = magnet
    }
    
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var downbtn: UIButton!
    
    @IBAction func reload(sender: AnyObject) {
        webview?.reload()
    }
    
    @IBOutlet weak var progressView: UIProgressView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initWebView()
        startRequest()
    }
    
    deinit {
        self.webview?.removeObserver(self, forKeyPath: "title")
        self.webview?.removeObserver(self, forKeyPath: "estimatedProgress")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    private func startRequest() {
        let url = NSURL(string: "http://替换成你懂的域名/index.php")!
        
        let request = NSMutableURLRequest(URL: url)
        request.addValue("ismob=1", forHTTPHeaderField: "Cookie")
        
        webview?.loadRequest(request)
    }
    
    private func initWebView() {
        let userContentController = WKUserContentController()
        let cookieScript = WKUserScript(source: "document.cookie='ismob=1';",
                                        injectionTime: .AtDocumentStart, forMainFrameOnly: false)
        let downScript = WKUserScript(source: self.loadFile(), injectionTime: .AtDocumentEnd, forMainFrameOnly: false)
        userContentController.addUserScript(cookieScript)
        userContentController.addUserScript(downScript)
        userContentController.addScriptMessageHandler(self, name: "NativeInterface")
        
        let webViewConfig = WKWebViewConfiguration()
        webViewConfig.userContentController = userContentController
        
        webview = WKWebView(frame: self.view.bounds, configuration: webViewConfig);
        webview?.allowsBackForwardNavigationGestures = true
        
        webview?.addObserver(self, forKeyPath: "title", options: .New, context: nil)
        webview?.addObserver(self, forKeyPath: "estimatedProgress", options: .New, context: nil)
        
        self.view.insertSubview(webview!, atIndex: 0)
    }
    
    private func loadFile()-> String {
        let bundle = NSBundle.mainBundle()
        let path = bundle.pathForResource("main", ofType: "js")
        var js = ""
        do {
            js = try String(contentsOfFile: path!)
        } catch let error as NSError {
            print("Failed reading from URL: \(path), Error: " + error.localizedDescription)
        }
        return js
    }
    
    func userContentController(userContentController: WKUserContentController, didReceiveScriptMessage message: WKScriptMessage) {
        let dict = message.body as! Dictionary<String,String>
        print(dict)
        let code = dict["url"]
        if code != "" {
            backgroundView.hidden = false
            downbtn.hidden = false
            magnet = "magnet:?xt=urn:btih:" + code!;
        }
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        
        if let path = keyPath {
            switch path {
            case "title":
                self.title = self.webview?.title
                backgroundView.hidden = true
                downbtn.hidden = true
            case "estimatedProgress":
                progressView.hidden = webview?.estimatedProgress == 1
                progressView.setProgress(Float((webview?.estimatedProgress)!), animated: true)
            default:
                break
            }
        }
    }
    
}

