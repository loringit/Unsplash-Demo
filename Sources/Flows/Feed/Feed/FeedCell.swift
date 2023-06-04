//
//  FeedCell.swift
//  Unsplash-Demo
//
//  Created by Булат Якупов on 04.06.2023.
//

import Nuke
import UIKit

class FeedCell: UICollectionViewCell {
    
    private let cornerRadius: CGFloat = 10
    
    // MARK: - Subviews
    
    private lazy var cardView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = cornerRadius
        if traitCollection.userInterfaceStyle != .dark {
            view.layer.shadowColor = UIColor.gray.cgColor
            view.layer.shadowOpacity = 1
            view.layer.shadowOffset = .zero
            view.layer.shadowRadius = 3
        }
        return view
    }()
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = cornerRadius
        
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
    
    func setup(with item: PhotoItem) {
        Task {
            let request = ImageRequest(url: item.smallURL)
            if let container = ImagePipeline.shared.cache.cachedImage(for: request) {
                imageView.image = container.image
            } else {
                imageView.image = try await ImagePipeline.shared.image(for: request)
            }
        }
    }
    
    // MARK: - Private methods
    
    private func setupLayout() {
        addSubview(cardView)
        cardView.addSubview(imageView)

        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: topAnchor, constant: 6),
            cardView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -6),
            cardView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 6),
            cardView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -6),
            
            imageView.topAnchor.constraint(equalTo: cardView.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: cardView.bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor)
        ])
    }
    
}
