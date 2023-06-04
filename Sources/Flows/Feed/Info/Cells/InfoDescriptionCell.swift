//
//  InfoDescriptionCell.swift
//  Unsplash-Demo
//
//  Created by Булат Якупов on 05.06.2023.
//

import UIKit

class InfoDescriptionCell: UITableViewCell {
    
    // MARK: - Subview
    
    private lazy var label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .Bold.base
        label.textColor = .Text.primary
        label.numberOfLines = 0
        return label
    }()
    
    // MARK: - Public properties
    
    var text: String? {
        didSet {
            label.text = text
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
        contentView.addSubview(label)
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 9),
            label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -9),
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 18),
            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -18)
        ])
    }
    
}
