//
//  DownloadViewController.swift
//  Unsplash-Demo
//
//  Created by Булат Якупов on 05.06.2023.
//

import Combine
import UIKit

class DownloadViewController: UIViewController {
    
    // MARK: - Subviews
    
    private lazy var progressView: ProgressView = {
        let view = ProgressView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.actionTitle = viewModel.actionTitle
        view.resultTitle = viewModel.resultTitle
        view.resultIsHidden = true
        return view
    }()
        
    // MARK: - Private properties
    
    private let viewModel: IDownloadViewModel
    private var subscriptions = Set<AnyCancellable>()
    
    // MARK: - Lifecycle
    
    init(viewModel: IDownloadViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .Background.primary
        setupLayout()
        setupBindings()
    }
    
    // MARK: - Private methods
    
    private func setupLayout() {
        view.addSubview(progressView)
        NSLayoutConstraint.activate([
            progressView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            progressView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 18),
            progressView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -18)
        ])
    }
    
    private func setupBindings() {
        viewModel
            .downloadProgressPublisher
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { [weak self] progress in
                    self?.progressView.update(progress: progress.0, totalSize: progress.1)
                    if progress.0 == 1.0 {
                        self?.progressView.resultIsHidden = false
                    }
                }
            )
            .store(in: &subscriptions)
    }
    
}

