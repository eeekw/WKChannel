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
        let options = message["options"] as? Dictionary<String, Any> ?? [:]
        let callback = options["callback"] as? String
                
        event = WKChannelEvent(name: name, arguments: arguments, options: options)
        if let cb = callback {
            self.callback = WKChannelCallback(name: cb, arguments: [:], options: [:])
        }
        
        debugPrint("WKChannel: context", self)
    }
}

public struct WKChannelEvent: WKChannelMessage {
    public var name: String
    public var arguments: Dictionary<String, Any>
    public var options: Dictionary<String, Any>
}

public struct WKChannelCallback: WKChannelMessage {
    public var name: String
    public var arguments: Dictionary<String, Any>
    public var options: Dictionary<String, Any>
    
    public init(name: String, arguments: Dictionary<String, Any> = [:], options: Dictionary<String, Any> = [:]) {
        self.name = name
        self.arguments = arguments
        self.options = options
    }
    
    public func toString() -> String {
        do {
            let json = try JSONSerialization.data(withJSONObject: arguments)
            let optJson = try JSONSerialization.data(withJSONObject: options)
            return "\(name)(\(String(data: json, encoding: .utf8) ?? ""), \(String(data: optJson, encoding: .utf8) ?? "" ))"
        } catch {
            debugPrint("Invalid format: please check your callback arguments")
            return name
        }
    }
}
