//
//  Authorizer.swift
//  Unsplash-Demo
//
//  Created by Булат Якупов on 02.06.2023.
//

import AppAuth
import Combine
import Foundation
import KeychainAccess
import UIKit

protocol Authorizer {
    
    var token: String? { get }
    var idToken: String? { get }
    var tokenPublisher: AnyPublisher<String?, Error> { get }
    
    func login(from controller: UIViewController) -> AnyPublisher<Void, Error>
    func checkToken() -> AnyPublisher<String, Error>
    func logout()
    
}

protocol AuthFlowHolder: AnyObject {
    
    var currentAuthorizationFlow: OIDExternalUserAgentSession? { get set }
    
}

class AppAuthAuthorizer: Authorizer {
    
    // MARK: - Private properties
    
    private let keychain = Keychain(service: Bundle.main.bundleIdentifier ?? "com.meshcapade.me")
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()
    private let authStateKey = "com.meshcapade.auth.state"
    private let tokenSubject = CurrentValueSubject<String?, Error>(nil)
    private let authFlowHolder: AuthFlowHolder
    
    private let configuration: OIDServiceConfiguration
    private var authState: OIDAuthState? {
        get {
            do {
                guard
                    let dataAsString = try keychain.get(authStateKey),
                    let data = Data(base64Encoded: dataAsString)
                else {
                    return nil
                }
                
                return try NSKeyedUnarchiver.unarchivedObject(ofClass: OIDAuthState.self, from: data)
            } catch {
                print("\(#fileID) \(#line): \(error)")
                return nil
            }
        }
        set {
            guard let newValue = newValue else {
                tokenSubject.send(newValue?.lastTokenResponse?.accessToken)
                return
            }
            
            do {
                let data = try NSKeyedArchiver.archivedData(withRootObject: newValue, requiringSecureCoding: true)
                let string = data.base64EncodedString()
                try keychain.set(string, key: authStateKey)
            } catch {
                print("\(#fileID) \(#line): \(error)")
            }
            
            tokenSubject.send(newValue.lastTokenResponse?.accessToken)
        }
    }
    
    // MARK: - Lifecycle
    
    init(authFlowHolder: AuthFlowHolder) {
        let authorizationEndpoint = URL(string: "https://unsplash.com/oauth/authorize")!
        let tokenEndpoint = URL(string: "https://unsplash.com/oauth/token")!
        self.configuration = OIDServiceConfiguration(
            authorizationEndpoint: authorizationEndpoint,
            tokenEndpoint: tokenEndpoint
        )
        self.authFlowHolder = authFlowHolder
        logout()
        tokenSubject.send(token)
        
        #if DEBUG
        print(authState?.lastTokenResponse?.accessToken)
        #endif
    }
    
    // MARK: - Authorizer
    
    var token: String? {
        authState?.lastTokenResponse?.accessToken
    }
    
    var idToken: String? {
        authState?.lastTokenResponse?.idToken
    }
    
    var tokenPublisher: AnyPublisher<String?, Error> {
        tokenSubject.eraseToAnyPublisher()
    }
    
    func login(from controller: UIViewController) -> AnyPublisher<Void, Error> {
        let loginSubject = PassthroughSubject<Void, Error>()
        
        let request = OIDAuthorizationRequest(
            configuration: self.configuration,
            clientId: CLIENT_ID,
            clientSecret: CLIENT_SECRET,
            scope: "public read_user write_likes",
            redirectURL: URL(string: "unsplash-demo:/"),
            responseType: "code",
            state: nil,
            nonce: nil,
            codeVerifier: nil,
            codeChallenge: nil,
            codeChallengeMethod: nil,
            additionalParameters: nil
        )
        
        self.authFlowHolder.currentAuthorizationFlow = OIDAuthState
            .authState(
                byPresenting: request,
                presenting: controller,
                callback: { [weak self] authState, error in
                    guard let `self` = self else { return }
                    
                    if let authState = authState {
                        self.authState = authState
                        
                        #if DEBUG
                        print(authState.lastTokenResponse?.accessToken)
                        #endif
                        
                        loginSubject.send(())
                    } else {
                        print("Authorization error: \(error?.localizedDescription ?? "Unknown error")")
                        self.authState = nil
                        
                        if let error = error {
                            loginSubject.send(completion: .failure(error))
                        }
                    }
                }
            )
        
        return loginSubject.eraseToAnyPublisher()
    }
    
    func checkToken() -> AnyPublisher<String, Error> {
        let tokenSubject = PassthroughSubject<String, Error>()
        
        guard let authState = authState else {
            tokenSubject.send(completion: .failure(RequestError.noToken))
            return tokenSubject.eraseToAnyPublisher()
        }
        
        authState.performAction { [weak self] (accessToken, idToken, error) in
            guard error == nil else {
                self?.logout()
                tokenSubject.send(completion: .failure(RequestError.badRequest(error!)))
                return
            }
            
            if let accessToken = accessToken {
                tokenSubject.send(accessToken)
            } else {
                tokenSubject.send(completion: .failure(RequestError.noToken))
            }
        }
        
        return tokenSubject.eraseToAnyPublisher()
    }
    
    func logout() {
        self.authState = nil
        try? self.keychain.removeAll()
    }
    
}
