//
//  File.swift
//  
//
//  Created by Leaf on 2021/4/11.
//

public typealias WKChannelNext<T> = (T, @escaping (T, @escaping (T) -> Void) -> Void) -> Void
public typealias WKChannelMiddleware<T> = (T, (WKChannelNext<T>)) -> Void

typealias WKChannelComposeReturn<T> = (T, ((T) -> Void)?) -> Void

func compose<T: Any>(_ fns: [WKChannelMiddleware<T>]) -> WKChannelComposeReturn<T> {
    
    func exec(_ context: T, _ done: ((T) -> Void)?) -> Void {
        
        var index = -1
        func dispatch(_ i: Int, _ context: T, _ callback: @escaping (T) -> Void) {
            
            guard index == i else {
                debugPrint("WKChannelNext function called multiple times")
                return
            }
            
            index = i
            if index == fns.count {
                callback(context)
                return
            }
            
            let fn = fns[i]
            fn(context) { (context: T, pre: @escaping (T, @escaping (T) -> Void) -> Void)  in
                dispatch(i + 1, context) { (ctx: T) in
                    pre(ctx) {(c: T) in
                        callback(c)
                    }
                }
            }
        }
        
        dispatch(0, context) {(context: T) in
            guard let _done = done else {
                return
            }
            _done(context)
        }
    }
        
    return exec
}
