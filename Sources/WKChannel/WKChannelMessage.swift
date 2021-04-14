//
//  WKChannelMessage.swift
//  WKChannel
//
//  Created by Leaf on 2021/4/14.
//

public protocol WKChannelMessage {
    var name: String { get }
    var arguments: Dictionary<String, Any> { get }
    var options: Dictionary<String, Any> { get }
    
    func toString() -> String
}

extension WKChannelMessage {
    
    public func toString() -> String {
        return ""
    }
}
