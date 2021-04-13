//
//  WKChannelProtocol.swift
//  WKChannel
//
//  Created by Leaf on 2021/4/13.
//

import WebKit

public protocol WKChannelReceive {
    mutating func call(_ message: Any, _ webView: WKWebView) -> Void
}

public protocol WKChannelProtocol: WKChannelReceive {
    
    var middlewares: [WKChannel.Middleware] {
        get set
    }
    
    mutating func add(_ fn: @escaping WKChannel.Middleware) -> Void
}

extension WKChannelProtocol {
            
    public mutating func add(_ fn: @escaping WKChannel.Middleware) -> Void {
        middlewares.append(fn)
    }
    
    public mutating func process(_ message: Any, _ webView: WKWebView) -> Void {
        let fn = compose(middlewares)
        
        debugPrint("WKChannel: start")
        debugPrint("WKChannel: receive")
        
        guard let msg = message as? Dictionary<String, Any> else {
            debugPrint("Invalid format: please check your message!")
            return
        }
        
        guard let m = msg["name"] as? String else {
            debugPrint("Invalid format: please check your event name")
            return
        }
        
        guard m != "" else {
            debugPrint("Invalid value: please check your event name")
            return
        }
         
        debugPrint("WKChannel: create context")
        let context = WKChannelContext(msg)
        
        debugPrint("WKChannel: call middleware")
        fn(context) { context in
            guard let callback = context.callback else {
                debugPrint("WKChannel: end")
                return
            }
            debugPrint("WKChannel: send callback")
            webView.evaluateJavaScript(callback.toString()) { (data: Any?, error: Error?) in
                debugPrint("WKChannel: callback ", (error == nil) ? "completes": "fails")
                debugPrint("Callback: ", error ?? data ?? "empty")
                debugPrint("WKChannel: end")
            }
        }
    }
    
    public mutating func call(_ message: Any, _ webView: WKWebView) -> Void {
        process(message, webView)
    }
}
