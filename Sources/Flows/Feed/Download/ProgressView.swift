//
//  ProgressView.swift
//  Unsplash-Demo
//
//  Created by Булат Якупов on 05.06.2023.
//

import UIKit

class ProgressView: UIView {
    
    // MARK: - Subviews
    
    private let progressView: UIProgressView = {
        let view = UIProgressView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .ProgressView.background
        view.progressTintColor = .ProgressView.progressTint
        return view
    }()
    private let infoLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .Text.primary
        label.numberOfLines = 0
        label.font = .Regular.base
        label.textAlignment = .center
        return label
    }()
    private let uploadLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .Text.primary
        label.numberOfLines = 0
        label.textAlignment = .left
        label.font = .Regular.small
        label.isHidden = true
        return label
    }()
    private let progressLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .Text.primary
        label.font = .Regular.small
        label.numberOfLines = 0
        label.textAlignment = .right
        label.isHidden = true
        return label
    }()
    
    // MARK: - Public properties
    
    var actionTitle: String = "" {
        didSet {
            uploadLabel.text = actionTitle
        }
    }
    var resultTitle: String = "" {
        didSet {
            infoLabel.text = resultTitle
        }
    }
    var resultIsHidden = false {
        didSet {
            infoLabel.isHidden = resultIsHidden
            progressLabel.isHidden = !resultIsHidden
            uploadLabel.isHidden = !resultIsHidden
            progressView.isHidden = !resultIsHidden
        }
    }
        
    // MARK: - Init
    
    init() {
        super.init(frame: .zero)
        layout()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layout()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        layout()
    }
    
    // MARK: - Private methods
    
    private func layout() {
        addSubview(progressView)
        addSubview(progressLabel)
        addSubview(uploadLabel)
        addSubview(infoLabel)
        
        NSLayoutConstraint.activate([
            progressView.leadingAnchor.constraint(equalTo: leadingAnchor),
            progressView.trailingAnchor.constraint(equalTo: trailingAnchor),
            progressView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            progressLabel.bottomAnchor.constraint(equalTo: progressView.topAnchor, constant: -20),
            progressLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            uploadLabel.bottomAnchor.constraint(equalTo: progressView.topAnchor, constant: -20),
            uploadLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            
            infoLabel.bottomAnchor.constraint(equalTo: progressView.topAnchor, constant: -20),
            infoLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            infoLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            infoLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
        ])
    }
    
    // MARK: - Public methods
    
    func update(progress: Double, totalSize: Int64) {
        infoLabel.isHidden = true
        progressLabel.isHidden = false
        uploadLabel.isHidden = false
        progressView.isHidden = false
        
        if progress < 1.0 {
            let byteCountFormatter: ByteCountFormatter = ByteCountFormatter()
            byteCountFormatter.countStyle = ByteCountFormatter.CountStyle.file
            byteCountFormatter.allowedUnits = ByteCountFormatter.Units.useMB
            byteCountFormatter.zeroPadsFractionDigits = true
            byteCountFormatter.isAdaptive = true
            let size = byteCountFormatter.string(fromByteCount: totalSize)
            let uploadedSize = byteCountFormatter.string(fromByteCount: Int64(Double(totalSize) * progress))
            
            self.progressLabel.text = "\(uploadedSize)/\(size)"
        }
        
        self.progressView.progress = Float(progress)
    }
    
}
