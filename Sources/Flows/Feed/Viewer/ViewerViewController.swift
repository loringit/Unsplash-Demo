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
                self?.viewModel.tapLike()
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
                self?.viewModel.tapDownload()
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
                self?.viewModel.tapInfo()
            }),
            for: .touchUpInside
        )
        
        return infoButton
    }()
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.tintColor = .Text.primary
        activityIndicator.hidesWhenStopped = true
        return activityIndicator
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
        setImage(from: viewModel.photoItem)
        setTitle(from: viewModel.photoItem)
        setLikeButton(viewModel.photoItem.isLiked)
        activityIndicator.startAnimating()
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
        view.addSubview(activityIndicator)
        view.addSubview(imageView)
        view.addSubview(likeButton)
        view.addSubview(downloadButton)
        view.addSubview(infoButton)
        
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
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
            .isLikedPublisher
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { result in
                    switch result {
                    case .failure(let error):
                        print("\(#fileID) \(#line): \(error)")
                    case .finished:
                        print("\(#fileID) \(#line): Finished")
                    }
                },
                receiveValue: { [weak self] isLiked in
                    guard let self else { return }
                    self.setLikeButton(isLiked)
                }
            )
            .store(in: &subscriptions)
    }
    
    // MARK: Data updates
    
    private func setImage(from item: PhotoItem) {
        Task {
            let request = ImageRequest(url: item.mediumURL)
            if let container = ImagePipeline.shared.cache.cachedImage(for: request) {
                imageView.image = container.image
            } else {
                imageView.image = try await ImagePipeline.shared.image(for: request)
            }
            activityIndicator.stopAnimating()
        }
    }
    
    private func setLikeButton(_ isLiked: Bool) {
        likeButton.configuration?.baseForegroundColor = isLiked ? .Text.danger : .Text.primary
    }
    
    private func setTitle(from item: PhotoItem) {
        navigationItem.title = item.user.name
    }
    
    // MARK: Navigation actions
    
    @objc private func backAction() {
        viewModel.tapBack()
    }
    
    @objc private func shareAction() {
        viewModel.tapShare()
    }
    
}
