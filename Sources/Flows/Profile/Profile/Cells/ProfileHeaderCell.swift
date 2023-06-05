//
//  ProfileHeaderCell.swift
//  Unsplash-Demo
//
//  Created by Булат Якупов on 05.06.2023.
//

import Nuke
import UIKit

class ProfileHeaderCell: UITableViewCell {
    
    // MARK: - Subviews
    
    private lazy var avatarView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 50
        return imageView
    }()
    
    private lazy var nameLabel: UILabel = {
        let nameLabel = UILabel()
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.textColor = .Text.primary
        nameLabel.font = .Heading.title
        nameLabel.numberOfLines = 0
        nameLabel.textAlignment = .center
        return nameLabel
    }()
    
    private lazy var bioLabel: UILabel = {
        let bioLabel = UILabel()
        bioLabel.translatesAutoresizingMaskIntoConstraints = false
        bioLabel.textColor = .Text.primary
        bioLabel.font = .Regular.base
        bioLabel.numberOfLines = 0
        nameLabel.textAlignment = .center
        return bioLabel
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 18
        stackView.distribution = .equalCentering
        stackView.alignment = .center
        return stackView
    }()
    
    // MARK: - Public properties
    
    var model: ProfileHeaderModel? {
        didSet {
            guard let model else { return }
            
            avatarView.isHidden = model.avatar == nil
            if let avatar = model.avatar {
                Task {
                    let request = ImageRequest(url: avatar)
                    if let container = ImagePipeline.shared.cache.cachedImage(for: request) {
                        avatarView.image = container.image
                    } else {
                        avatarView.image = try await ImagePipeline.shared.image(for: request)
                    }
                }
            }
            
            nameLabel.text = model.name
            nameLabel.isHidden = model.name == nil
            
            bioLabel.text = model.bio
            bioLabel.isHidden = model.bio == nil
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
        stackView.addArrangedSubview(avatarView)
        stackView.addArrangedSubview(nameLabel)
        stackView.addArrangedSubview(bioLabel)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 18),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -18),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 18),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -18),
            
            avatarView.heightAnchor.constraint(equalToConstant: 100),
            avatarView.widthAnchor.constraint(equalToConstant: 100)
        ])
    }
    
}
