//
//  FeedCell.swift
//  Unsplash-Demo
//
//  Created by Булат Якупов on 04.06.2023.
//

import Nuke
import UIKit

class FeedCell: UICollectionViewCell {
    
    // MARK: - Subviews
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 10
        return imageView
    }()
    
    // MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func prepareForReuse() {
        super.prepareForReuse()
    }
    
    // MARK: - Public methods
    
    func setup(with item: FeedItem) {
        Task {
            let imageTask = ImagePipeline.shared.imageTask(with: item.smallURL)
            imageView.image = try await imageTask.image
        }
    }
    
    // MARK: - Private methods
    
    private func setupLayout() {
        addSubview(imageView)

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
    
}
