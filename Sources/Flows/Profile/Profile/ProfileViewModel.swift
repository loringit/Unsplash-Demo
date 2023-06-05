//
//  ProfileViewModel.swift
//  Unsplash-Demo
//
//  Created by Булат Якупов on 05.06.2023.
//

import Combine
import Foundation

enum ProfileViewModelOut {
    
    case openURL(URL)
    
}

protocol IProfileViewModel {
    
    var out: ((ProfileViewModelOut) -> ())? { get set }
    
    var reloadSubject: AnySubject<Void, Never> { get }
    var openUrlSubject: AnySubject<URL, Never> { get }
    var profilePublisher: AnyPublisher<[ProfileCellType], Error> { get }
    
}

class ProfileViewModel: IProfileViewModel {
    
    // MARK: - Public properties
    
    var out: ((ProfileViewModelOut) -> ())?
    
    let reloadSubject = AnySubject<Void, Never>(PassthroughSubject())
    let openUrlSubject = AnySubject<URL, Never>(PassthroughSubject())
    lazy var profilePublisher: AnyPublisher<[ProfileCellType], Error> = createProfilePublisher()
    
    // MARK: - Private properties
    
    private let unsplashService: IUnsplashService
    @Atomic private var user: UserDTO?
    private var subscriptions = Set<AnyCancellable>()
    
    // MARK: - Lifecycle
    
    init(unsplashService: IUnsplashService) {
        self.unsplashService = unsplashService
        self.bindInputs()
    }
    
    // MARK: - Private methods
    
    private func bindInputs() {
        openUrlSubject
            .sink(receiveValue: { [weak self] url in
                self?.out?(.openURL(url))
            })
            .store(in: &subscriptions)
    }
    
    private func createProfilePublisher() -> AnyPublisher<[ProfileCellType], Error> {
        reloadSubject
            .map { [weak self] in
                guard let self else {
                    return Empty<[ProfileCellType], Error>().eraseToAnyPublisher()
                }
                
                return self.unsplashService
                    .getUserProfile()
                    .map {
                        [
                            .header(ProfileHeaderModel(dto: $0)),
                            .counters(ProfileCountersModel(dto: $0)),
                            .links(ProfileLinksModel(dto: $0))
                        ]
                    }
                    .eraseToAnyPublisher()
            }
            .switchToLatest()
            .eraseToAnyPublisher()
    }
    
}
