//
//  ProfileLinksCell.swift
//  Unsplash-Demo
//
//  Created by Булат Якупов on 05.06.2023.
//

import UIKit

class ProfileLinksCell: UITableViewCell {
    
    // MARK: - Subviews
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 18
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        return stackView
    }()
    
    // MARK: - Public properties
    
    var openURL: ((URL) -> ())?
    
    var model: ProfileLinksModel? {
        didSet {
            guard let model else { return }
            
            createLinks(from: model).forEach { stackView.addArrangedSubview($0) }
        }
    }
    
    // MARK: - Lifecycle
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private methods
    
    private func setupLayout() {
        contentView.backgroundColor = .Background.primary
        
        contentView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 18),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -18),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 18),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -18)
        ])
    }
    
    private func createLinks(from model: ProfileLinksModel) -> [UIStackView] {
        var buttons = [UIButton]()
        
        if let instagram = model.instagram {
            buttons.append(
                createButton(image: .instagram, title: "Instagram", color: .SocialNetworks.instagram, textColor: .Text.primary.dark, url: instagram)
            )
        }
        
        if let twitter = model.twitter {
            buttons.append(
                createButton(image: .twitter, title: "Twitter", color: .SocialNetworks.twitter, textColor: .Text.primary.dark, url: twitter)
            )
        }
        
        if let website = model.website {
            buttons.append(
                createButton(image: .globe, title: "Portfolio", color: .Button.primary, textColor: .Text.secondary, url: website)
            )
        }
        
        func createRowStack() -> UIStackView {
            let stackView = UIStackView()
            stackView.translatesAutoresizingMaskIntoConstraints = false
            stackView.axis = .horizontal
            stackView.spacing = 18
            stackView.distribution = .fillEqually
            stackView.alignment = .fill
            return stackView
        }
        
        var stacks: [UIStackView]
        if buttons.count == 3 {
            stacks = [createRowStack(), createRowStack()]
            stacks[0].addArrangedSubview(buttons[0])
            stacks[0].addArrangedSubview(buttons[1])
            stacks[1].addArrangedSubview(buttons[2])
        } else {
            stacks = [createRowStack()]
            buttons.forEach { stacks[0].addArrangedSubview($0) }
        }
        
        return stacks
    }
    
    private func createButton(image: UIImage, title: String, color: UIColor, textColor: UIColor, url: URL) -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = color
        button.layer.cornerRadius = 10
        button.addAction(
            UIAction(handler: { [weak self] _ in
                self?.openURL?(url)
            }),
            for: .touchUpInside
        )
        
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.tintColor = textColor
        imageView.image = image
        
        let label = UILabel()
        label.text = title
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .Heading.title
        label.textAlignment = .left
        label.textColor = textColor
        
        button.addSubview(imageView)
        button.addSubview(label)
        
        NSLayoutConstraint.activate([
            button.heightAnchor.constraint(equalToConstant: (UIScreen.main.bounds.width - 18 * 3) / 2),
            
            imageView.leadingAnchor.constraint(equalTo: button.leadingAnchor, constant: 9),
            imageView.topAnchor.constraint(equalTo: button.topAnchor, constant: 9),
            
            label.leadingAnchor.constraint(equalTo: button.leadingAnchor, constant: 9),
            label.bottomAnchor.constraint(equalTo: button.bottomAnchor, constant: -9)
        ])
        
        return button
    }
    
}
