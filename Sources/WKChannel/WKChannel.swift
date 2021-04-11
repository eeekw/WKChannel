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
    
    private var middlewares = [Middleware]()
            
    public mutating func add(_ fn: @escaping Middleware) -> Void {
        middlewares.append(fn)
    }
    
    mutating func call(_ message: Any, _ webView: WKWebView) -> Void {
        let fn = compose(middlewares)
        
        let context = WKChannelContext(message)
        
        fn(context) { ctx in
            webView.evaluateJavaScript(ctx.callback.toString()) { (data: Any?, error: Error?) in
                print(data ?? "no data", error ?? "no error", separator: "---", terminator: ":end")
            }
        }
    }
}

public struct WKChannelContext {
    var event: WKChannelEvent
    var callback: WKChannelCallback
    
    init(_ message: Any) {
        
        let msg = message as! Dictionary<String, Any>
        
        event = WKChannelEvent(name: msg["name"] as! String, arguments: msg["arguments"] as! Dictionary<String, Any>)
        callback = WKChannelCallback(name: msg["callback"] as! String, arguments: [:])
        
    }
}

public struct WKChannelEvent {
    var name: String
    var arguments: Dictionary<String, Any>
}

public struct WKChannelCallback {
    var name: String
    var arguments: Dictionary<String, Any>
    func toString() -> String {
        return "\(name)(\(arguments))"
    }
}
