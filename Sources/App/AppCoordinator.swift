//
//  AppCoordinator.swift
//  Unsplash-Demo
//
//  Created by Булат Якупов on 02.06.2023.
//

import Combine
import UIKit

protocol IAppCoordinator: AnyObject {
    
    var window: UIWindow { get set }
    func start()
    
}

class AppCoordinator: IAppCoordinator {
    
    // MARK: - Public Properties
    
    var window: UIWindow
    
    // MARK: - Private Properties
    
    private var tabCoordinator: ITabCoordinator
    private let dependencyContainer: IDependencyContainer
    private var subscriptions = Set<AnyCancellable>()

    // MARK: - Lifecycle
    
    init(
        window: UIWindow,
        dependencyContainer: IDependencyContainer
    ) {
        self.window = window
        self.dependencyContainer = dependencyContainer
        
        let tabBarController = UITabBarController()
        tabCoordinator = TabCoordinator(
            tabBarController: tabBarController,
            container: dependencyContainer
        )
    }
    
    // MARK: - Public Methods
    
    func start() {        
        dependencyContainer
            .requestService
            .authorizationPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { result in
                switch result {
                case .failure(let error):
                    print("\(#fileID) \(#line): \(error)")
                case .finished:
                    print("\(#fileID) \(#line): Finished")
                }
            }, receiveValue: { [weak self] isAuthorized in
                if isAuthorized {
                    self?.showMainFlow()
                } else {
                    self?.showAuth()
                }
            })
            .store(in: &subscriptions)
    }
    
    // MARK: - Private methods
    
    private func showAuth() {
        let vc = AuthorizationViewController(requestService: dependencyContainer.requestService)
        vc.out = { [weak self] cmd in
            switch cmd {
            case .authorized:
                self?.showMainFlow()
            }
        }
        
        window.rootViewController = vc
        window.makeKeyAndVisible()
    }
    
    private func showMainFlow() {
        window.rootViewController = tabCoordinator.tabBarController
        window.makeKeyAndVisible()
        
        tabCoordinator.start()
    }
    
}
