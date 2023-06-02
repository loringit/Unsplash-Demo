//
//  AppCoordinator.swift
//  Unsplash-Demo
//
//  Created by Булат Якупов on 02.06.2023.
//

import UIKit

protocol IWindowCoordinator: AnyObject {
    
    var window: UIWindow { get set }
    func start()
    var didFinishClosure: (() -> ())? { get set }
    
}

class AppCoordinator: IWindowCoordinator {
    
    // MARK: - Public Properties
    
    var didFinishClosure: (() -> ())?
    var window: UIWindow
    
    // MARK: - Private Properties
    
    private let dependencyContainer: IDependencyContainer

    // MARK: - Lifecycle
    
    init(
        window: UIWindow,
        dependencyContainer: IDependencyContainer
    ) {
        self.window = window
        self.dependencyContainer = dependencyContainer
    }
    
    // MARK: - Public Methods
    
    func start() {

    }
    
    // MARK: - Private methods
    
}
