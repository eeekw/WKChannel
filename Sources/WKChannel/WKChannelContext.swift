//
//  WKChannelContext.swift
//  WKChannel
//
//  Created by Leaf on 2021/4/13.
//

import Foundation

public struct WKChannelContext {
    public var event: WKChannelEvent
    public var callback: WKChannelCallback?
    
    init(_ message: Dictionary<String, Any>) {
        
        let name = message["name"] as! String
        let arguments = message["arguments"] as? Dictionary<String, Any> ?? [:]
        let callback = message["callback"] as? String
                
        event = WKChannelEvent(name: name, arguments: arguments)
        if let cb = callback {
            self.callback = WKChannelCallback(name: cb, arguments: [:])
        }
        
        debugPrint("WKChannel: context", self)
    }
}

public struct WKChannelEvent {
    public var name: String
    public var arguments: Dictionary<String, Any>
}

public struct WKChannelCallback {
    public var name: String
    public var arguments: Dictionary<String, Any>
    public func toString() -> String {
        do {
            let json = try JSONSerialization.data(withJSONObject: arguments)
            return "\(name)(\(String(data: json, encoding: .utf8) ?? ""))"
        } catch {
            debugPrint("Invalid format: please check your callback arguments")
            return name
        }
    }
}
