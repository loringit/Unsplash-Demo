//
//  InfoPropertyCell.swift
//  Unsplash-Demo
//
//  Created by Булат Якупов on 05.06.2023.
//

import UIKit

class InfoPropertyCell: UITableViewCell {
    
    // MARK: - Subview
    
    private lazy var propertyLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .Bold.small
        label.textColor = .Text.primary
        return label
    }()
    
    private lazy var valueLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .Regular.small
        label.textColor = .Text.primary
        return label
    }()
    
    // MARK: - Public properties
    
    var property: String? {
        didSet {
            propertyLabel.text = property
        }
    }
    
    var value: String? {
        didSet {
            valueLabel.text = value
        }
    }
    
    // MARK: - Lifecycle
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .Background.primary
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private methods
    
    private func setupLayout() {
        contentView.addSubview(propertyLabel)
        contentView.addSubview(valueLabel)
        
        NSLayoutConstraint.activate([
            propertyLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 9),
            propertyLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -9),
            propertyLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 18),
            propertyLabel.trailingAnchor.constraint(greaterThanOrEqualTo: valueLabel.leadingAnchor, constant: -5),
            
            valueLabel.topAnchor.constraint(equalTo: propertyLabel.topAnchor),
            valueLabel.bottomAnchor.constraint(equalTo: propertyLabel.bottomAnchor),
            valueLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -18)
        ])
    }
    
}
