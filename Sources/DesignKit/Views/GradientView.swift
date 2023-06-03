//
//  GradientView.swift
//  Unsplash-Demo
//
//  Created by Булат Якупов on 03.06.2023.
//

import UIKit

class GradientView: UIView {
    
    var locations: [NSNumber]? {
        didSet {
            gradient?.locations = locations
        }
    }
    var colors: [Any]? {
        didSet {
            gradient?.colors = colors
        }
    }
    var startPoint: CGPoint = .zero {
        didSet {
            gradient?.startPoint = startPoint
        }
    }
    var endPoint: CGPoint = .zero {
        didSet {
            gradient?.endPoint = endPoint
        }
    }
    var type: CAGradientLayerType = .axial {
        didSet {
            gradient?.type = type
        }
    }
    
    private var gradient: CAGradientLayer?
    
    init() {
        super.init(frame: .zero)
        setupGradient()
        
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        gradient?.frame = bounds
    }
    
    private func setupGradient() {
        let gradient: CAGradientLayer = CAGradientLayer()
        layer.insertSublayer(gradient, at: 0)
        gradient.frame = bounds
        self.gradient = gradient
    }
    
}
