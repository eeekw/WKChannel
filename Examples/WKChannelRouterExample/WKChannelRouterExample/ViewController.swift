//
//  ViewController.swift
//  WKChannelRouterExample
//
//  Created by Leaf on 2021/4/13.
//

import UIKit
import WebKit
import WKChannel
import WKChannelRouter

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        var router = WKChannelRouter()
        
        router.add("WKChannelRouter") { (context, next) in
            debugPrint("WKChannelRouter: ", context)
            next(context) { (context, pre) in
                pre(context)
            }
        }
        
        var channel = WKChannel()
        channel.add(router.routes())
        
        var connect = WKChannelConnect(channel)
        
        let userContentController = WKUserContentController()
        userContentController.add(connect.scriptMessageHandler, name: connect.name)
        
        let configuration = WKWebViewConfiguration()
        configuration.userContentController = userContentController
        
        let webView = WKWebView(frame: CGRect.zero, configuration: configuration)
        webView.load(URLRequest(url: URL(string: "https://www.baidu.com")!))
        self.view.addSubview(webView)
        webView.translatesAutoresizingMaskIntoConstraints = false
        
        let leading = NSLayoutConstraint(item: webView, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leadingMargin, multiplier: 1.0, constant: 0.0)
        let trailing = NSLayoutConstraint(item: webView, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailingMargin, multiplier: 1.0, constant: 0.0)
        
        let top = NSLayoutConstraint(item: webView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .topMargin, multiplier: 1.0, constant: 0.0)
        let bottom = NSLayoutConstraint(item: webView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottomMargin, multiplier: 1.0, constant: 0.0)
        
        NSLayoutConstraint.activate([leading, trailing, top, bottom])
        
        webView.evaluateJavaScript("""
                    window.webkit.messageHandlers.WKCHANNEL_NAME_DEFAULT.postMessage({
                    name: "WKChannelRouter",
                    arguments: {a: 1,b: 2}
                    })
                    window.webkit.messageHandlers.WKCHANNEL_NAME_DEFAULT.postMessage({
                    name: "WKChannelOther",
                    arguments: {a: 1,b: 2}
                    })
                    """, completionHandler: nil)
    }
    
    
}

