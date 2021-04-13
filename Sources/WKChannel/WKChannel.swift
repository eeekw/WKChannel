//
//  File.swift
//  
//
//  Created by Leaf on 2021/4/10.
//

import WebKit

public struct WKChannel {
            
//    private lazy var handlers = [String: Any]()
//
//    public mutating func add(_ channelHandler: WKChannelHandler, name: String) -> Void {
//        handlers[name] = channelHandler
//    }
//
//    public mutating func add(_ channelHandler: @escaping () -> Void, name: String) -> Void {
//        handlers[name] = channelHandler
//    }
    
    public typealias Middleware = WKChannelMiddleware<WKChannelContext>
    public typealias MiddlewareNext = WKChannelMiddlewareNext<WKChannelContext>
    public typealias MiddlewarePre = WKChannelMiddlewarePre<WKChannelContext>
    public typealias MiddlewareCallback = WKChannelMiddlewareCallback<WKChannelContext>
    
    private var middlewares = [Middleware]()
    
    public init() {
        
    }
            
    public mutating func add(_ fn: @escaping Middleware) -> Void {
        middlewares.append(fn)
    }
    
    mutating func call(_ message: Any, _ webView: WKWebView) -> Void {
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
}
