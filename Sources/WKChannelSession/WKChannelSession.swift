//
//  WKChannelSession.swift
//  WKChannel
//
//  Created by Leaf on 2021/4/13.
//

import WebKit
import WKChannel

public class WKChannelSession: WKChannelProtocol {
    public var middlewares = [WKChannel.Middleware]()
    
    public var webView: WKWebView?
    
    var sessions = [String: WKChannel]()
    
    public func get(_ name: String) -> WKChannel {
        guard let session = sessions[name] else {
            let instance = WKChannel()
            sessions[name] = instance
            return instance
        }
        return session
    }
    
    public init() {
        
    }
    
    public func call(_ message: Any, _ webView: WKWebView) {
        guard let session = ((message as? Dictionary<String, Any>)?["options"] as? Dictionary<String, String>)?["session"] else {
            return
        }
        
        guard let channel = sessions[session] else {
            return
        }
        channel.add { (context: WKChannelContext, next: @escaping WKChannel.MiddlewareNext) in
            next(context) { (context, pre) in
                var context = context
                context.callback?.options["session"] = session
                pre(context)
            }
        }
        channel.call(message, webView)
    }
}
