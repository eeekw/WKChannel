//
//  WKChannelSession.swift
//  WKChannel
//
//  Created by Leaf on 2021/4/13.
//

import WebKit
import WKChannel

public struct WKChannelSession: WKChannelProtocol {
    public var middlewares = [WKChannel.Middleware]()
    
    var sessions = [String: WKChannel]()
    
    public mutating func get(_ name: String) -> WKChannel {
        guard let session = sessions[name] else {
            let instance = WKChannel()
            sessions[name] = instance
            return instance
        }
        return session
    }
    
    public init() {
        
    }
    
    public mutating func call(_ message: Any, _ webView: WKWebView) {
        guard let session = (message as? Dictionary<String, Dictionary<String, String>>)?["options"]?["session"] else {
            return
        }
        
        guard var channel = sessions[session] else {
            return
        }
        channel.call(message, webView)
    }
}
