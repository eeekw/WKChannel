//
//  ViewController.swift
//  WKChannelExample
//
//  Created by Leaf on 2021/4/12.
//

import UIKit
import WebKit
import WKChannel

class ViewController: UIViewController, WKNavigationDelegate {

    var channel: WKChannel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        var channel = WKChannel()
        self.channel = channel
        channel.add { (context: WKChannelContext, next: WKChannelMiddlewareNext) in
            if context.event.name == "printMiddleware" {
                debugPrint("WKChannelExample: first middleware")
                debugPrint("WKChannelExample: event is \(context.event)")
                var context = context
                context.event.arguments["newKey"] = "newValue"
                next(context) { context, pre in
                    debugPrint("WKChannelExample: first middleware")
                    debugPrint("WKChannelExample: callback is \(String(describing: context.callback))")
                    pre(context)
                }
                return
            }
            next(context) { context, pre in
                pre(context)
            }
        }
        
        channel.add { (context: WKChannelContext, next: WKChannelMiddlewareNext) in
            if context.event.name == "printMiddleware" {
                debugPrint("WKChannelExample: second middleware")
                debugPrint("WKChannelExample: event is \(context.event)")
                next(context) { context, pre in
                    var context = context
                    guard var cb = context.callback else {
                        pre(context)
                        return
                    }
                    cb.arguments["newNumber"] = 999
                    cb.arguments["newString"] = "newValue"
                    context.callback = cb
                    debugPrint("WKChannelExample: second middleware")
                    debugPrint("WKChannelExample: callback is \(String(describing: context.callback))")
                    pre(context)
                }
                return
            }
            next(context) { context, pre in
                pre(context)
            }
        }
        
        channel.add { (context: WKChannelContext, next: WKChannelMiddlewareNext) in
            if context.event.name == "printCallback" {
                debugPrint("WKChannelExample: printCallback")
                debugPrint("WKChannelExample: context is \(context)")
            }
            next(context) { context, pre in
                pre(context)
            }
        }
        
        channel.add { (context: WKChannelContext, next: WKChannelMiddlewareNext) in
            if context.event.name == "printPost" {
                debugPrint("WKChannelExample: printPost")
                debugPrint("WKChannelExample: context is \(context)")
            }
            next(context) { context, pre in
                pre(context)
            }
        }
        
        var connect = WKChannelConnect(channel)
        
        let userContentController = WKUserContentController()
        userContentController.add(connect.scriptMessageHandler, name: connect.name)
        userContentController.addUserScript(connect.channelScript)
        
        let configuration = WKWebViewConfiguration()
        configuration.userContentController = userContentController
        
        let webView = WKWebView(frame: CGRect.zero, configuration: configuration)
        webView.navigationDelegate = self
        webView.load(URLRequest(url: URL(string: "https://www.baidu.com")!))
        self.view.addSubview(webView)
        webView.translatesAutoresizingMaskIntoConstraints = false
        
        let leading = NSLayoutConstraint(item: webView, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leadingMargin, multiplier: 1.0, constant: 0.0)
        let trailing = NSLayoutConstraint(item: webView, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailingMargin, multiplier: 1.0, constant: 0.0)
        
        let top = NSLayoutConstraint(item: webView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .topMargin, multiplier: 1.0, constant: 0.0)
        let bottom = NSLayoutConstraint(item: webView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottomMargin, multiplier: 1.0, constant: 0.0)
        
        NSLayoutConstraint.activate([leading, trailing, top, bottom])
    }
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        webView.evaluateJavaScript("""
            window.webkit.messageChannelHandler = function (parameter) {
                window.webkit.messageHandlers[window.webkit.messageChannel].postMessage(parameter)
                return "Evaluate JavaScript: return"
            }
            window.webkit.messageHandlers[window.webkit.messageChannel].postMessage({
            name: "printMiddleware",
            })
            window.webkit.messageHandlers[window.webkit.messageChannel].postMessage({
            name: "eventName",
            arguments: {a: 1,b: 2},
            options: {callback: "printCallback"}
            })
            """, completionHandler: nil)
        
        channel?.webView = webView
        channel?.post(WKChannelCallback(name: "printPost"))
    }
}

