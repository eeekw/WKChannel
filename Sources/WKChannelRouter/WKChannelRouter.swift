//
//  WKChannelRouter.swift
//  WKChannel
//
//  Created by Leaf on 2021/4/12.
//

import WKChannel

public struct WKChannelRouter {
    
    var _routes = [String: WKChannel.Middleware]()
    
    public init() {
        
    }
    
    public mutating func add(_ name: String, middleware: @escaping WKChannel.Middleware) -> Void {
        _routes[name] = middleware
    }
    
    public func routes() -> WKChannel.Middleware {
        
        func middleware(context: WKChannelContext, next: @escaping WKChannel.MiddlewareNext) -> Void {
            let name = context.event.name
            guard let middleware = _routes[name] else {
                next(context) { (context, pre) in
                    pre(context)
                }
                return
            }
            
            middleware(context, next)
        }
        
        return middleware
    }
}
