//
//  File.swift
//  
//
//  Created by Leaf on 2021/4/10.
//

import WebKit

public struct WKChannel: WKChannelProtocol {
    
    public var middlewares = [Middleware]()
    
    public var webView: WKWebView?
    
    public init() {
        
    }
}

extension WKChannel {
    public typealias Middleware = WKChannelMiddleware<WKChannelContext>
    public typealias MiddlewareNext = WKChannelMiddlewareNext<WKChannelContext>
    public typealias MiddlewarePre = WKChannelMiddlewarePre<WKChannelContext>
    public typealias MiddlewareCallback = WKChannelMiddlewareCallback<WKChannelContext>
}
