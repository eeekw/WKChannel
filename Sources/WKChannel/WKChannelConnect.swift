
import WebKit

public struct WKChannelConnect {
    
    private let _name: String
    
    public var name: String {
        _name
    }
    
    private var _channel: WKChannel
    
    public var channel: WKChannel {
        get {
            _channel
        }
        set {
            _channel = newValue
        }
    }
    
    public lazy var scriptMessageHandler = {
        return WKChannelScriptMessageHandler(self)
    }()
    
    init(_ name: String = "WKCHANNEL_NAME_DEFAULT", _ channel: WKChannel) {
        _name = name
        _channel = channel
    }
}

public class WKChannelScriptMessageHandler: NSObject, WKScriptMessageHandler {
    
    private var _connect: WKChannelConnect
    
    init(_ connect: WKChannelConnect) {
        _connect = connect
    }
    
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard message.name == _connect.name else {
            return
        }
        _connect.channel.call(message.body, message.webView!)
    }
}
