//
//  Request.swift
//  Unsplash-Demo
//
//  Created by Булат Якупов on 02.06.2023.
//

import Foundation

enum RequestMethod: String {
    
    case options = "OPTIONS"
    case get     = "GET"
    case head    = "HEAD"
    case post    = "POST"
    case put     = "PUT"
    case patch   = "PATCH"
    case delete  = "DELETE"
    case trace   = "TRACE"
    case connect = "CONNECT"
    
}

enum RequestEncoding {
    
    case json
    case base
    case none
    
}

struct Request {
    
    // MARK: - Public properties
    var url: URL
    var method: RequestMethod
    var headers: [String: String]?
    var parameters: [String: Any]?
    var body: [String: Any]?
    var bodyData: Data?
    var encodableBody: Encodable?
    var encoding: RequestEncoding
    var encodedUrlString: String {
        var result = url.absoluteString
        if let parameters = parameters {
            var urlComponents = URLComponents()
            urlComponents.scheme = url.scheme
            urlComponents.host = url.host
            urlComponents.path = url.path
            urlComponents.queryItems = parameters.map { URLQueryItem(name: $0.key, value: "\($0.value)") }
            
            result = urlComponents.url!.path
        }
        
        return result
    }
    
    // MARK: - Private methods
    func urlRequest() -> URLRequest {
        var data: Data?
        if let body = body {
            switch encoding {
            case .base:
                var requestBodyComponents = URLComponents()
                requestBodyComponents.queryItems = body.map { URLQueryItem(name: $0.key, value: "\($0.value)") }
                data = requestBodyComponents.query?.data(using: .utf8)
            case .json:
                do {
                    data = try JSONSerialization.data(withJSONObject: body, options: .fragmentsAllowed)
                } catch {
                    #if DEBUG
                    print("\(#file) \(#line) \(error)")
                    #endif
                }
            case .none:
                break
            }
        } else if let encodableBody = encodableBody {
            do {
                let encodedData = try JSONEncoder().encode(encodableBody)
                data = encodedData
            } catch {
                print("\(#fileID) \(#line): \(error)")
            }
        } else if let bodyData = bodyData {
            data = bodyData
        }
                
        return _createRequest(method: method,
                              url: url,
                              parameters: parameters,
                              header: headers,
                              bodyData: data,
                              encoding: encoding)
    }
        
    // MARK: - Private methods
    private func _createRequest(method: RequestMethod,
                               url: URL,
                               parameters: [String: Any]?,
                               header: [String: String]?,
                               bodyData: Data?,
                               encoding: RequestEncoding) -> URLRequest {
        var url = url
        
        if let parameters = parameters {
            var urlComponents = URLComponents()
            urlComponents.scheme = url.scheme
            urlComponents.host = url.host
            urlComponents.path = url.path
            urlComponents.queryItems = parameters.map { URLQueryItem(name: $0.key, value: "\($0.value)") }
            
            url = urlComponents.url!
        }
        
        var request = URLRequest(url: url,
                                 cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
                                 timeoutInterval: 60)
        request.httpMethod = method.rawValue
        
        if let header = header {
            for (key, value) in header {
                request.setValue(value, forHTTPHeaderField: key)
            }
        }
        
        if let bodyData = bodyData {
            request.httpBody = bodyData
            switch encoding {
            case .base:
                request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            case .json:
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            case .none:
                break
            }
        }
        
        return request
    }
    
}
