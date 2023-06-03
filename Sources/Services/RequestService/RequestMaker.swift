//
//  RequestMaker.swift
//  Unsplash-Demo
//
//  Created by Булат Якупов on 02.06.2023.
//

import Combine
import Foundation
import UIKit

protocol IRequestService: AnyObject {
    
    var serverURL: URL { get }
    var defaultHeader: [String : String]? { get }
    var isAuthorized: Bool { get }
    var authorizationPublisher: AnyPublisher<Bool, Error> { get }
    
    func download(request: Request, to destination: URL) -> AnyPublisher<RequestProgress, Error>
    func make<T: Decodable>(request: Request) -> AnyPublisher<T, Error>
    func login(from controller: UIViewController) -> AnyPublisher<Void, Error>
    
}

let CLIENT_ID = "QyAvLb6zPAfWvm2JbOd-EoHmnpIEuoRBOwMSgsB0_Z0"
let CLIENT_SECRET = "qMvFEX-ooHG4htISUutcqb-0A6nY3e4w1zOFtSOEEEg"

class RequestService: NSObject, IRequestService {
    
    // MARK: - Public properties
    var serverURL: URL = URL(string: "https://api.unsplash.com/")!
    var defaultHeader: [String : String]? {
        if let token = authorizer.token {
            return [
                "Authorization": "Bearer \(token)"
            ]
        } else {
            return [
                "Authorization": "Client-ID \(CLIENT_ID)"
            ]
        }
    }
    var backgroundCompletionHandler: (() -> Void)?
    
    var isAuthorized: Bool {
        authorizer.token != nil
    }
    var authorizationPublisher: AnyPublisher<Bool, Error> {
        authorizer.tokenPublisher.map { $0 != nil }.share().eraseToAnyPublisher()
    }
    
    // MARK: - Private properties
    
    private let authorizer: Authorizer
    private var subscriptions = Set<AnyCancellable>()
    // Initializing dateFormatter takes a lot of time, so it's importat to do it once and cache.
    private lazy var dateFormatter1: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS'Z'"
        return dateFormatter
    }()
    private lazy var dateFormatter2: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        return dateFormatter
    }()
    private lazy var decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(dateFormatter1)
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()
    
    //  MARK: - Lifecycle
    
    init(authorizer: Authorizer) {
        self.authorizer = authorizer
        super.init()
        checkAuth()
    }
    
    // MARK: - Public methods
    
    func download(request: Request, to destination: URL) -> AnyPublisher<RequestProgress, Error> {
        fatalError()
    }
    
    func make<T: Decodable>(request: Request) -> AnyPublisher<T, Error> {
        let obs: AnyPublisher<T, Error> = makeForeground(request: request)
        
        return authorizer
            .checkToken()
            .flatMap { _ in return obs }
            .eraseToAnyPublisher()
    }
    
    func login(from controller: UIViewController) -> AnyPublisher<Void, Error> {
        authorizer.login(from: controller)
    }
    
    // MARK: - Private methods
    
    private func makeForeground<T: Decodable>(request: Request) -> AnyPublisher<T, Error> {
        let urlRequest = request.urlRequest()
        
        
        return URLSession.shared.dataTaskPublisher(for: urlRequest)
            .tryMap({ [weak self] element in
                guard let self else { throw RequestError.unknown }
                
                let data = element.data
                let response = element.response
                
                guard let response = response as? HTTPURLResponse else {
                    throw RequestError.notHttpResponse
                }
                
                if response.statusCode / 200 == 1 {
                    do {
                        if data.isEmpty {
                            let emptyJson = "{}".data(using: .utf8)!
                            let result = try JSONDecoder().decode(T.self, from: emptyJson)
                            return result
                        } else {
                            let result: T
                            if let _result = try? self.decoder.decode(T.self, from: data) {
                                result = _result
                            } else {
                                self.decoder.dateDecodingStrategy = .formatted(self.dateFormatter2)
                                result = try self.decoder.decode(T.self, from: data)
                                self.decoder.dateDecodingStrategy = .formatted(self.dateFormatter1)
                            }
                            return result
                        }
                    } catch {
                        self.decoder.dateDecodingStrategy = .formatted(self.dateFormatter1)
                        throw error
                    }
                } else if response.statusCode == 401 {
                    self.authorizer.logout()
                    throw RequestError.noToken
                } else {
                    do {
                        let result = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                        throw RequestError.serverError(result)
                    } catch {
                        throw error
                    }
                }
            })
            .eraseToAnyPublisher()
    }
    
    private func checkAuth() {
        authorizer.checkToken().sink(receiveCompletion: { _ in }, receiveValue: { _ in }).store(in: &subscriptions)
    }
    
}
