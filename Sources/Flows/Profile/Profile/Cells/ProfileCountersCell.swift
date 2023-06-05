//
//  ProfileCountersCell.swift
//  Unsplash-Demo
//
//  Created by Булат Якупов on 05.06.2023.
//

import UIKit

class ProfileCountersCell: UITableViewCell {
    
    // MARK: - Subviews
    
    private lazy var countersStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 18
        stackView.distribution = .fillEqually
        stackView.alignment = .center
        return stackView
    }()
    
    // MARK: - Public properties
    
    var model: ProfileCountersModel? {
        didSet {
            guard let model else { return }
            countersStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
            countersStackView.addArrangedSubview(createCounter(title: "Likes", value: model.likesCount))
            countersStackView.addArrangedSubview(createCounter(title: "Following", value: model.followingCount))
            countersStackView.addArrangedSubview(createCounter(title: "Followers", value: model.followersCount))
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
        
        contentView.addSubview(countersStackView)
        
        NSLayoutConstraint.activate([
            countersStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 18),
            countersStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -18),
            countersStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 18),
            countersStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -18)
        ])
    }
    
    private func createCounter(title: String, value: Int) -> UIView {
        let countLabel = UILabel()
        countLabel.translatesAutoresizingMaskIntoConstraints = false
        countLabel.font = .Bold.base
        countLabel.textColor = .Text.primary
        countLabel.text = "\(value)"
        countLabel.textAlignment = .center
        
        let nameLabel = UILabel()
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.font = .Regular.small
        nameLabel.textColor = .Text.primary
        nameLabel.text = title
        nameLabel.textAlignment = .center
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .equalCentering
        stackView.alignment = .center
        stackView.spacing = 9
        
        stackView.addArrangedSubview(countLabel)
        stackView.addArrangedSubview(nameLabel)
        
        return stackView
    }
    
}
