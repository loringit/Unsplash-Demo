//
//  AuthorizationViewController.swift
//  Unsplash-Demo
//
//  Created by Булат Якупов on 03.06.2023.
//

import Combine
import Localize_Swift
import UIKit

enum AuthorizationOutCmd {
    
    case authorized
    
}

class AuthorizationViewController: UIViewController {
    
    // MARK: - Subviews
    
    private lazy var backgroundView: UIImageView = {
        let backgroundView = UIImageView()
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.image = UIImage.authPhoto
        backgroundView.contentMode = .scaleAspectFill
        backgroundView.clipsToBounds = true
        view.addSubview(backgroundView)
        return backgroundView
    }()
    
    private lazy var gradientView: GradientView = {
        let gradientView = GradientView()
        gradientView.translatesAutoresizingMaskIntoConstraints = false
        gradientView.colors = [
            UIColor.Background.primary.cgColor,
            UIColor.Background.primary.withAlphaComponent(0).cgColor
        ]
        gradientView.locations = [0.0 , 0.7]
        gradientView.startPoint = CGPoint(x: 0.5, y: 1.0)
        gradientView.endPoint = CGPoint(x: 0.5, y: 0.0)
        backgroundView.addSubview(gradientView)
        return gradientView
    }()
    
    private lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont.Heading.title
        titleLabel.textColor = UIColor.Text.primary
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        titleLabel.text = "Welcome to Unsplash Demo.".localized()
        return titleLabel
    }()
    
    private lazy var subtitleLabel: UILabel = {
        let subtitleLabel = UILabel()
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.font = UIFont.Regular.base
        subtitleLabel.textColor = UIColor.Text.primary
        subtitleLabel.textAlignment = .center
        subtitleLabel.numberOfLines = 0
        subtitleLabel.text = "Some actions on Unsplash require authorization.".localized()
        return subtitleLabel
    }()

    private lazy var loginButton: UIButton = {
        let loginButton = BasicButton(style: .primary)
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        loginButton.title = "Proceed to Unsplash".localized()
        loginButton.addTarget(self, action: #selector(login), for: .touchUpInside)
        view.addSubview(loginButton)
        return loginButton
    }()
    
    private lazy var titleStack: UIStackView = {
        let titleStack = UIStackView()
        titleStack.translatesAutoresizingMaskIntoConstraints = false
        titleStack.axis = .vertical
        titleStack.spacing = 8
        titleStack.distribution = .equalCentering
        view.addSubview(titleStack)
        return titleStack
    }()

    // MARK: - Public properties
    
    var out: ((AuthorizationOutCmd) -> ())?
    
    // MARK: - Private properties
        
    private let requestService: IRequestService
    private var subscriptions = Set<AnyCancellable>()
    
    // MARK: - Lifecycle
    
    init(requestService: IRequestService) {
        self.requestService = requestService
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.Background.primary
        setupLayout()
    }
    
    // MARK: - Private methods
    private func setupLayout() {
        titleStack.addArrangedSubview(titleLabel)
        titleStack.addArrangedSubview(subtitleLabel)

        NSLayoutConstraint.activate([
            backgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: titleStack.topAnchor),
            backgroundView.topAnchor.constraint(equalTo: view.topAnchor),
            
            gradientView.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor),
            gradientView.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor),
            gradientView.bottomAnchor.constraint(equalTo: backgroundView.bottomAnchor),
            gradientView.heightAnchor.constraint(equalToConstant: 70),

            titleStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 18),
            titleStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -18),
            titleStack.bottomAnchor.constraint(equalTo: loginButton.topAnchor, constant: -36),
            titleStack.heightAnchor.constraint(greaterThanOrEqualToConstant: 72),

            loginButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 18),
            loginButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -18),
            loginButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -18),
            loginButton.heightAnchor.constraint(equalToConstant: 48)
        ])
    }
    
    @objc private func login() {
        requestService
            .login(from: self)
            .sink(
                receiveCompletion: { result in
                    switch result {
                    case .failure(let error):
                        print("\(#fileID) \(#line): \(error)")
                    case .finished:
                        print("\(#fileID) \(#line): Finished")
                    }
                },
                receiveValue: { [weak self] _ in
                    self?.out?(.authorized)
                }
            )
            .store(in: &subscriptions)
    }
    
}
