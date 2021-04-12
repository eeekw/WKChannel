//
//  File.swift
//  
//
//  Created by Leaf on 2021/4/11.
//

public typealias WKChannelMiddlewarePre<T> = (T) -> Void
public typealias WKChannelMiddlewareCallback<T> = (T, @escaping WKChannelMiddlewarePre<T>) -> Void
public typealias WKChannelMiddlewareNext<T> = (T, @escaping WKChannelMiddlewareCallback<T> ) -> Void
public typealias WKChannelMiddleware<T> = (T, @escaping (WKChannelMiddlewareNext<T>)) -> Void

typealias WKChannelComposeReturn<T> = (T, ((T) -> Void)?) -> Void

func compose<T: Any>(_ fns: [WKChannelMiddleware<T>]) -> WKChannelComposeReturn<T> {
    
    func exec(_ context: T, _ done: ((T) -> Void)?) -> Void {
        
        var index = -1
        func dispatch(_ i: Int, _ context: T, _ callback: @escaping (T) -> Void) {
            
            guard index != i else {
                debugPrint("WKChannelNext function called multiple times")
                return
            }
            
            index = i
            if index == fns.count {
                callback(context)
                return
            }
            
            let fn = fns[i]
            fn(context) {/* next */ (context: T, cb: @escaping WKChannelMiddlewareCallback<T>)  in
                dispatch(i + 1, context) { (ctx: T) in
                    cb(ctx) {/* pre */(c: T) in
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
