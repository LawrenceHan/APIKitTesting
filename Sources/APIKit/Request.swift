import Foundation
import Result

/// `Request` protocol represents a request for Web API.
/// Following 5 items must be implemented.
/// - `typealias Response`
/// - `var baseURL: URL`
/// - `var method: HTTPMethod`
/// - `var path: String`
/// - `func response(from object: Any, urlResponse: HTTPURLResponse) throws -> Response`
public protocol Request: RequestSerializable, ErrorHandleable {
    /// The response type associated with the request type.
    associatedtype Response: Decodable

    /// The base URL.
    var baseURL: URL { get }

    /// The HTTP request method.
    var method: HTTPMethod { get }

    /// The path URL component.
    var path: String { get }

    /// The convenience property for `queryParameters` and `bodyParameters`. If the implementation of
    /// `queryParameters` and `bodyParameters` are not provided, the values for them will be computed
    /// from this property depending on `method`.
    var parameters: Any? { get }

    /// The actual parameters for the URL query. The values of this property will be escaped using `URLEncodedSerialization`.
    /// If this property is not implemented and `method.prefersQueryParameter` is `true`, the value of this property
    /// will be computed from `parameters`.
    var queryParameters: [String: Any]? { get }

    /// The actual parameters for the HTTP body. If this property is not implemented and `method.prefersQueryParameter` is `false`,
    /// the value of this property will be computed from `parameters` using `JSONBodyParameters`.
    var bodyParameters: BodyParameters? { get }

    /// The HTTP header fields. In addition to fields defined in this property, `Accept` and `Content-Type`
    /// fields will be added by `dataParser` and `bodyParameters`. If you define `Accept` and `Content-Type`
    /// in this property, the values in this property are preferred.
    var headerFields: [String: String] { get }

    /// The parser object that states `Content-Type` to accept and parses response body.
    var dataParser: DataParser { get }
}

public extension Request {
    public var parameters: Any? {
        return nil
    }

    public var queryParameters: [String: Any]? {
        guard let parameters = parameters as? [String: Any], method.prefersQueryParameters else {
            return nil
        }

        return parameters
    }

    public var bodyParameters: BodyParameters? {
        guard let parameters = parameters, !method.prefersQueryParameters else {
            return nil
        }

        return JSONBodyParameters(JSONObject: parameters)
    }

    public var headerFields: [String: String] {
        return [:]
    }

    public var dataParser: DataParser {
        return JSONDataParser(readingOptions: [])
    }

    /// Builds `Response` from response `Data`.
    /// - Throws: `ResponseError`, `Error`
    public func parse(data: Data, urlResponse: HTTPURLResponse) throws -> Response {
        let parsedObject = try dataParser.parse(data: data)
        let passedObject = try intercept(object: parsedObject, urlResponse: urlResponse)
        return try Response.parse(json: passedObject)
    }
}
