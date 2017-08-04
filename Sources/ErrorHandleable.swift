//
//  ErrorHandleable.swift
//  APIKit
//
//  Created by Hanguang on 2017/8/5.
//  Copyright © 2017年 Yosuke Ishikawa. All rights reserved.
//

import Foundation

public protocol ErrorHandleable {
    /// Intercepts `URLRequest` which is created by `Request.buildURLRequest()`. If an error is
    /// thrown in this method, the result of `Session.send()` turns `.failure(.requestError(error))`.
    /// - Throws: `Error`
    func intercept(urlRequest: URLRequest) throws -> URLRequest
    
    /// Intercepts response `Any` and `HTTPURLResponse`. If an error is thrown in this method,
    /// the result of `Session.send()` turns `.failure(.responseError(error))`.
    /// The default implementation of this method is provided to throw `RequestError.unacceptableStatusCode`
    /// if the HTTP status code is not in `200..<300`.
    /// - Throws: `Error`
    func intercept(object: Any, urlResponse: HTTPURLResponse) throws -> Any
}

public extension ErrorHandleable {
    func intercept(urlRequest: URLRequest) throws -> URLRequest {
        print("Origin: \(#function)")
        return urlRequest
    }
    
    func intercept(object: Any, urlResponse: HTTPURLResponse) throws -> Any {
        print("Origin: \(#function)")
        guard 200..<300 ~= urlResponse.statusCode else {
            throw ResponseError.unacceptableStatusCode(urlResponse.statusCode)
        }
        return object
    }
}
