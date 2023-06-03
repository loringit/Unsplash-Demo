//
//  BasicButton.swift
//  Unsplash-Demo
//
//  Created by Булат Якупов on 03.06.2023.
//

import UIKit

enum BasicButtonStyle {
    
    case primary
    case secondary
    case danger
    
}
    
class BasicButton: UIButton {
    
    // MARK: - Public properties
    
    var title: String? {
        didSet {
            updateAttributedTitle(to: title)
        }
    }
    
    var subtitle: String? {
        didSet {
            updateAttributedSubtitle(to: subtitle)
        }
    }
    
    var image: UIImage? {
        didSet {
            updateImage(to: image)
        }
    }
    
    var style: BasicButtonStyle {
        didSet {
            updateStyle()
        }
    }
    
    // MARK: - Private properties
        
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.backgroundColor = .clear
        indicator.color = configuration?.baseForegroundColor
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        addSubview(indicator)
        NSLayoutConstraint.activate([
            indicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            indicator.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        return indicator
    }()
    
    // MARK: - Lifecycle
    
    init(style: BasicButtonStyle) {
        self.style = style
        super.init(frame: .zero)
        self.configuration = UIButton.Configuration.filled()
        updateStyle()
        activityIndicator.isHidden = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public methods
    
    func startActivity() {
        isEnabled = false
        activityIndicator.startAnimating()
        configuration?.image = nil
        configuration?.attributedTitle = nil
        configuration?.attributedSubtitle = nil
    }
    
    func stopActivity() {
        updateStyle()
        activityIndicator.stopAnimating()
        isEnabled = true
    }
    
    // MARK: - Private methods

    private func updateAttributedTitle(to title: String?) {
        var container = AttributeContainer()
        container.font = UIFont.Bold.base
        
        switch style {
        case .primary:
            container.foregroundColor = UIColor.Text.secondary
        case .secondary:
            container.foregroundColor = UIColor.Text.primary
        case .danger:
            container.foregroundColor = UIColor.Text.primary.dark
        }
        
        configuration?.attributedTitle = AttributedString(title ?? "", attributes: container)
        configuration?.titleAlignment = .center
    }
    
    private func updateAttributedSubtitle(to subtitle: String?) {
        var container = AttributeContainer()
        container.font = UIFont.Regular.xsmall
        
        switch style {
        case .primary:
            container.foregroundColor = UIColor.Text.secondary
        case .secondary:
            container.foregroundColor = UIColor.Text.primary
        case .danger:
            container.foregroundColor = UIColor.Text.primary.dark
        }
        
        if let subtitle = subtitle {
            configuration?.attributedSubtitle = AttributedString(subtitle, attributes: container)
        } else {
            configuration?.attributedSubtitle = nil
        }
        
    }
    
    private func updateImage(to image: UIImage?) {
        configuration?.image = image
        configuration?.imagePadding = 10
        
        switch style {
        case .primary:
            configuration?.baseForegroundColor = UIColor.Text.secondary
        case .secondary:
            configuration?.baseForegroundColor = UIColor.Text.primary
        case .danger:
            configuration?.baseForegroundColor = UIColor.Text.primary.dark
        }
        
    }
    
    private func updateStyle() {
        configuration?.background.cornerRadius = 12
        
        switch style {
        case .primary:
            configuration?.baseBackgroundColor = UIColor.Button.primary
        case .secondary:
            configuration?.baseBackgroundColor = UIColor.Button.secondary
        case .danger:
            configuration?.baseBackgroundColor = UIColor.Button.danger
        }
        
        updateAttributedTitle(to: title)
        updateAttributedSubtitle(to: subtitle)
        updateImage(to: image)
    }
    
}
