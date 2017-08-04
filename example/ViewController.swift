//
//  ViewController.swift
//  example
//
//  Created by Hanguang on 2017/8/3.
//  Copyright © 2017年 Yosuke Ishikawa. All rights reserved.
//

import UIKit
import APIKit

//: Step 1: Define request protocol
protocol GitHubRequest: Request {
    
}

extension GitHubRequest {
    var baseURL: URL {
        return URL(string: "https://api.github.com")!
    }
    
//    func buildURLRequest() throws -> URLRequest {
//        print("Github Hello world!!")
//        let url = path.isEmpty ? baseURL : baseURL.appendingPathComponent(path)
//        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
//            throw RequestError.invalidBaseURL(baseURL)
//        }
//        
//        var urlRequest = URLRequest(url: url)
//        
//        if let queryParameters = queryParameters, !queryParameters.isEmpty {
//            components.percentEncodedQuery = URLEncodedSerialization.string(from: queryParameters)
//        }
//        
//        if let bodyParameters = bodyParameters {
//            urlRequest.setValue(bodyParameters.contentType, forHTTPHeaderField: "Content-Type")
//            
//            switch try bodyParameters.buildEntity() {
//            case .data(let data):
//                urlRequest.httpBody = data
//                
//            case .inputStream(let inputStream):
//                urlRequest.httpBodyStream = inputStream
//            }
//        }
//        
//        urlRequest.url = components.url
//        urlRequest.httpMethod = method.rawValue
//        urlRequest.setValue(dataParser.contentType, forHTTPHeaderField: "Accept")
//        
//        headerFields.forEach { key, value in
//            urlRequest.setValue(value, forHTTPHeaderField: key)
//        }
//        
//        return (try intercept(urlRequest: urlRequest) as URLRequest)
//    }
//    
//    func intercept(object: Any, urlResponse: HTTPURLResponse) throws -> Any {
//        print("Github asdklfjakls;djfl;kadsjfl;kjs")
//        guard 200..<300 ~= urlResponse.statusCode else {
//            throw ResponseError.unacceptableStatusCode(urlResponse.statusCode)
//        }
//        return object
//    }
}

//: Step 2: Create model object
struct RateLimit {
    let count: Int
    let resetDate: Date
    
    init?(dictionary: [String: AnyObject]) {
        guard let count = dictionary["rate"]?["limit"] as? Int else {
            return nil
        }
        
        guard let resetDateString = dictionary["rate"]?["reset"] as? TimeInterval else {
            return nil
        }
        
        self.count = count
        self.resetDate = Date(timeIntervalSince1970: resetDateString)
    }
}

//: Step 3: Define request type conforming to created request protocol
// https://developer.github.com/v3/rate_limit/
struct GetRateLimitRequest: GitHubRequest {
    typealias Response = RateLimit
    
    var method: HTTPMethod {
        return .get
    }
    
    var path: String {
        return "/rate_limit"
    }
    
    func response(from object: Any, urlResponse: HTTPURLResponse) throws -> Response {
        guard let dictionary = object as? [String: AnyObject],
            let rateLimit = RateLimit(dictionary: dictionary) else {
                throw ResponseError.unexpectedObject(object)
        }
        
        return rateLimit
    }
    
//    func buildURLRequest() throws -> URLRequest {
//        print("Sub-Protocol: \(#function)")
//        let url = path.isEmpty ? baseURL : baseURL.appendingPathComponent(path)
//        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
//            throw RequestError.invalidBaseURL(baseURL)
//        }
//        
//        var urlRequest = URLRequest(url: url)
//        
//        if let queryParameters = queryParameters, !queryParameters.isEmpty {
//            components.percentEncodedQuery = URLEncodedSerialization.string(from: queryParameters)
//        }
//        
//        if let bodyParameters = bodyParameters {
//            urlRequest.setValue(bodyParameters.contentType, forHTTPHeaderField: "Content-Type")
//            
//            switch try bodyParameters.buildEntity() {
//            case .data(let data):
//                urlRequest.httpBody = data
//                
//            case .inputStream(let inputStream):
//                urlRequest.httpBodyStream = inputStream
//            }
//        }
//        
//        urlRequest.url = components.url
//        urlRequest.httpMethod = method.rawValue
//        urlRequest.setValue(dataParser.contentType, forHTTPHeaderField: "Accept")
//        
//        headerFields.forEach { key, value in
//            urlRequest.setValue(value, forHTTPHeaderField: key)
//        }
//        
//        return (try intercept(urlRequest: urlRequest) as URLRequest)
//    }
//    
//    func intercept(urlRequest: URLRequest) throws -> URLRequest {
//        print("Sub-Protocol: \(#function)")
//        return urlRequest
//    }
//    
//    func intercept(object: Any, urlResponse: HTTPURLResponse) throws -> Any {
//        print("Sub-Protocol: \(#function)")
//        guard 200..<300 ~= urlResponse.statusCode else {
//            throw ResponseError.unacceptableStatusCode(urlResponse.statusCode)
//        }
//        return object
//    }
}

//extension RequestSerializable where Self: APIKit.Request {
//    func buildURLRequest() throws -> URLRequest {
//        print("Extension: \(#function)")
//        let url = path.isEmpty ? baseURL : baseURL.appendingPathComponent(path)
//        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
//            throw RequestError.invalidBaseURL(baseURL)
//        }
//        
//        var urlRequest = URLRequest(url: url)
//        
//        if let queryParameters = queryParameters, !queryParameters.isEmpty {
//            components.percentEncodedQuery = URLEncodedSerialization.string(from: queryParameters)
//        }
//        
//        if let bodyParameters = bodyParameters {
//            urlRequest.setValue(bodyParameters.contentType, forHTTPHeaderField: "Content-Type")
//            
//            switch try bodyParameters.buildEntity() {
//            case .data(let data):
//                urlRequest.httpBody = data
//                
//            case .inputStream(let inputStream):
//                urlRequest.httpBodyStream = inputStream
//            }
//        }
//        
//        urlRequest.url = components.url
//        urlRequest.httpMethod = method.rawValue
//        urlRequest.setValue(dataParser.contentType, forHTTPHeaderField: "Accept")
//        
//        headerFields.forEach { key, value in
//            urlRequest.setValue(value, forHTTPHeaderField: key)
//        }
//        
//        return (try intercept(urlRequest: urlRequest) as URLRequest)
//    }
//}
//
//extension ErrorHandleable {
//    func intercept(urlRequest: URLRequest) throws -> URLRequest {
//        print("Extension: \(#function)")
//        return urlRequest
//    }
//    
//    func intercept(object: Any, urlResponse: HTTPURLResponse) throws -> Any {
//        print("Extension: \(#function)")
//        guard 200..<300 ~= urlResponse.statusCode else {
//            throw ResponseError.unacceptableStatusCode(urlResponse.statusCode)
//        }
//        return object
//    }
//}

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let request = GetRateLimitRequest()
        
        Session.send(request) { result in
            switch result {
            case .success(let rateLimit):
                print("count: \(rateLimit.count)")
                print("reset: \(rateLimit.resetDate)")
                
            case .failure(let error):
                print("error: \(error)")
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

