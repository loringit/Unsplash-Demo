//
//  ViewerViewController.swift
//  Unsplash-Demo
//
//  Created by Булат Якупов on 04.06.2023.
//

import Combine
import Nuke
import UIKit

class ViewerViewController: UIViewController {
    
    // MARK: - Subviews
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var likeButton: BasicButton = {
        let likeButton = BasicButton(style: .secondary)
        likeButton.translatesAutoresizingMaskIntoConstraints = false
        likeButton.image = .heart
        
        likeButton.addAction(
            UIAction(handler: { [weak self] _ in
                self?.viewModel.tapLikeSubject.send()
            }),
            for: .touchUpInside
        )
        
        return likeButton
    }()
    
    private lazy var downloadButton: BasicButton = {
        let downloadButton = BasicButton(style: .primary)
        downloadButton.translatesAutoresizingMaskIntoConstraints = false
        downloadButton.image = .download
        
        downloadButton.addAction(
            UIAction(handler: { [weak self] _ in
                self?.viewModel.tapDownloadSubject.send()
            }),
            for: .touchUpInside
        )
        
        return downloadButton
    }()
    
    private lazy var infoButton: BasicButton = {
        let infoButton = BasicButton(style: .secondary)
        infoButton.translatesAutoresizingMaskIntoConstraints = false
        infoButton.image = .info
        
        infoButton.addAction(
            UIAction(handler: { [weak self] _ in
                self?.viewModel.tapInfoSubject.send()
            }),
            for: .touchUpInside
        )
        
        return infoButton
    }()
    
    // MARK: - Private properties
    
    private let viewModel: IViewerViewModel
    private var subscriptions = Set<AnyCancellable>()
    
    // MARK: - Lifecycle
    
    init(viewModel: IViewerViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .Background.primary
        
        setupNavBar()
        setupLayout()
        setupBindings()
    }
    
    // MARK: - Private methods
    
    // MARK: Setup
    
    private func setupNavBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: .arrowLeft,
            style: .plain,
            target: self,
            action: #selector(backAction)
        )
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: .share,
            style: .plain,
            target: self,
            action: #selector(shareAction)
        )
    }
    
    private func setupLayout() {
        view.addSubview(imageView)
        view.addSubview(likeButton)
        view.addSubview(downloadButton)
        view.addSubview(infoButton)
        
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            downloadButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -18),
            downloadButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -36),
            downloadButton.widthAnchor.constraint(equalToConstant: 54),
            downloadButton.heightAnchor.constraint(equalToConstant: 54),
            
            likeButton.trailingAnchor.constraint(equalTo: downloadButton.trailingAnchor),
            likeButton.bottomAnchor.constraint(equalTo: downloadButton.topAnchor, constant: -18),
            likeButton.widthAnchor.constraint(equalToConstant: 54),
            likeButton.heightAnchor.constraint(equalToConstant: 54),
            
            infoButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 18),
            infoButton.bottomAnchor.constraint(equalTo: downloadButton.bottomAnchor),
            infoButton.widthAnchor.constraint(equalToConstant: 54),
            infoButton.heightAnchor.constraint(equalToConstant: 54)
        ])
    }
    
    private func setupBindings() {
        viewModel
            .photoItemPublisher
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { [weak self] photoItem in
                    guard let self else { return }
                    
                    if self.imageView.image == nil {
                        self.setImage(from: photoItem)
                        self.setTitle(from: photoItem)
                    }
                    self.setLikeButton(from: photoItem)
                }
            )
            .store(in: &subscriptions)
    }
    
    // MARK: Data updates
    
    private func setImage(from item: PhotoItem) {
        Task {
            let request = ImageRequest(url: item.fullURL)
            if let container = ImagePipeline.shared.cache.cachedImage(for: request) {
                imageView.image = container.image
            } else {
                imageView.image = try await ImagePipeline.shared.image(for: request)
            }
        }
    }
    
    private func setLikeButton(from item: PhotoItem) {
        likeButton.configuration?.baseForegroundColor = item.isLiked ? .Text.danger : .Text.primary
    }
    
    private func setTitle(from item: PhotoItem) {
        navigationItem.title = item.user.name
    }
    
    // MARK: Navigation actions
    
    @objc private func backAction() {
        viewModel.tapBackSubject.send()
    }
    
    @objc private func shareAction() {
        viewModel.tapShareSubject.send()
    }
    
}
