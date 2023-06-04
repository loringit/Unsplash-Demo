//
//  FeedCoordinator.swift
//  Unsplash-Demo
//
//  Created by Булат Якупов on 02.06.2023.
//

import Combine
import UIKit

protocol IFeedCoordinator: AnyObject {
    
    var navigationController: UINavigationController { get }
    func start()
    
}

class FeedCoordinator: NSObject, IFeedCoordinator {
    
    // MARK: - Public properties
    
    let navigationController: UINavigationController
    
    // MARK: - Private properties
    
    private var dependancyContainer: IDependencyContainer
    private var subscriptions = Set<AnyCancellable>()
    
    // MARK: - Init
    
    init(navigationController: UINavigationController, dependancyContainer: IDependencyContainer) {
        self.navigationController = navigationController
        self.dependancyContainer = dependancyContainer
        super.init()
        self.setupNavigationController()
    }
    
    // MARK: - Public methods
    
    func start() {
        showFeed()
    }
    
    // MARK: - Private methods
    
    // MARK: Setup
    
    private func setupNavigationController() {
        navigationController.delegate = self
        navigationController.navigationBar.backgroundColor = .Background.primary
        navigationController.navigationBar.barTintColor = .Background.primary
        navigationController.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.Text.primary]
        navigationController.navigationBar.tintColor = .Text.primary
        navigationController.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController.navigationBar.shadowImage = UIImage()
    }
    
    // MARK: Routing
    
    private func showFeed() {
        let viewModel = FeedViewModel(unsplashService: dependancyContainer.unsplashService)
        viewModel.out = { [weak self] out in
            switch out {
            case .open(let item):
                self?.showViewer(item)
            }
        }
        
        let viewController = FeedViewController(viewModel: viewModel)
        navigationController.pushViewController(viewController, animated: false)
    }
    
    private func showViewer(_ item: PhotoItem) {
        let viewModel = ViewerViewModel(unsplashService: dependancyContainer.unsplashService, item: item)
        viewModel.out = { [weak self] out in
            switch out {
            case .back:
                self?.navigationController.popViewController(animated: true)
            case .info:
                self?.showInfo(for: item)
            case .share:
                let activityVC = UIActivityViewController(activityItems: [item.shareURL], applicationActivities: nil)
                self?.navigationController.topViewController?.present(activityVC, animated: true)
            case .download:
                let viewModel = DownloadViewModel(item: item)
                viewModel.out = { [weak self] out in
                    switch out {
                    case .finished:
                        self?.navigationController.topViewController?.dismiss(animated: true)
                    }
                }
                let viewController = DownloadViewController(viewModel: viewModel)
                self?.navigationController.topViewController?.present(viewController, animated: true)
            }
        }
        
        let viewController = ViewerViewController(viewModel: viewModel)
        viewController.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(viewController, animated: false)
    }
    
    private func showInfo(for item: PhotoItem) {
        let viewController = InfoViewController(item: item)
        navigationController.topViewController?.present(viewController, animated: true)
    }
    
}

extension FeedCoordinator: UINavigationControllerDelegate {
    
    func navigationController(
        _ navigationController: UINavigationController,
        willShow viewController: UIViewController,
        animated: Bool
    ) {
        if viewController is ViewerViewController {
            navigationController.setNavigationBarHidden(false, animated: animated)
        } else {
            navigationController.setNavigationBarHidden(true, animated: animated)
        }
    }
    
}

