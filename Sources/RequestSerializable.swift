//
//  RequestSerializable.swift
//  APIKit
//
//  Created by Hanguang on 2017/8/4.
//  Copyright © 2017年 Yosuke Ishikawa. All rights reserved.
//

import Foundation

public protocol RequestSerializable {
    /// Builds `URLRequest` from `POPAPIKit.Request`.
    /// - Throws: `RequestError`, `Error`
    func buildURLRequest() throws -> URLRequest
}

public extension RequestSerializable where Self: APIKit.Request {
    func buildURLRequest() throws -> URLRequest {
        print("Origin: \(#function)")
        let url = path.isEmpty ? baseURL : baseURL.appendingPathComponent(path)
        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            throw RequestError.invalidBaseURL(baseURL)
        }
        
        var urlRequest = URLRequest(url: url)
        
        if let queryParameters = queryParameters, !queryParameters.isEmpty {
            components.percentEncodedQuery = URLEncodedSerialization.string(from: queryParameters)
        }
        
        if let bodyParameters = bodyParameters {
            urlRequest.setValue(bodyParameters.contentType, forHTTPHeaderField: "Content-Type")
            
            switch try bodyParameters.buildEntity() {
            case .data(let data):
                urlRequest.httpBody = data
                
            case .inputStream(let inputStream):
                urlRequest.httpBodyStream = inputStream
            }
        }
        
        urlRequest.url = components.url
        urlRequest.httpMethod = method.rawValue
        urlRequest.setValue(dataParser.contentType, forHTTPHeaderField: "Accept")
        
        headerFields.forEach { key, value in
            urlRequest.setValue(value, forHTTPHeaderField: key)
        }
        
        return (try intercept(urlRequest: urlRequest) as URLRequest)
    }
}
