//
//  ViewController.swift
//  WKChannelExample
//
//  Created by Leaf on 2021/4/12.
//

import UIKit
import WebKit
import WKChannel

class ViewController: UIViewController {

    var webView: WKWebView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        var channel = WKChannel()
        channel.add { (context: WKChannelContext, next: WKChannelMiddlewareNext) in
            print("WKChannelExample: ", "first middleware: ", "event: ", context.event, separator: "\n--", terminator: "\n\n")
            var context = context
            context.event.arguments["newKey"] = "newValue"
            next(context) { context, pre in
                print("WKChannelExample: ", "first middleware: ", "callback: ", context.callback ?? "", separator: "\n--", terminator: "\n\n")
                pre(context)
            }
        }
        
        channel.add { (context: WKChannelContext, next: WKChannelMiddlewareNext) in
            print("WKChannelExample: ", "second middleware: ", "event: ", context.event, separator: "\n--", terminator: "\n\n")
            next(context) { context, pre in
                var context = context
                print("WKChannelExample: ", "second middleware: ", "callback: ", context.callback ?? "", separator: "\n--", terminator: "\n\n")
                guard var cb = context.callback else {
                    pre(context)
                    return
                }
                cb.arguments["newCallbackNumber"] = 999
                cb.arguments["newCallbackString"] = "newCallbackValue"
                context.callback = cb
                pre(context)
            }
        }
        
        channel.add { (context: WKChannelContext, next: WKChannelMiddlewareNext) in
            if context.event.name == "printCallback" {
                print("printCallback: ", context.event.arguments)
            }
            next(context) { context, pre in
                pre(context)
            }
        }
        
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
            name: "eventName",
            callback: "callbackName",
            arguments: {a: 1,b: 2}
            })
            function callbackName(parameter) {
                window.webkit.messageHandlers.WKCHANNEL_NAME_DEFAULT.postMessage({name: "printCallback", arguments: parameter})
                return "callback return"
            }
            """, completionHandler: nil)
    }
}

