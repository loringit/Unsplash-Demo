//
//  Fonts.swift
//  Unsplash-Demo
//
//  Created by Булат Якупов on 03.06.2023.
//

import UIKit

extension UIFont {
    
    struct Heading {
        
        static let title = UIFont.systemFont(ofSize: 24, weight: .semibold)
        
    }
    
    struct Regular {
        
        static let base = UIFont.systemFont(ofSize: 16, weight: .regular)
        static let small = UIFont.systemFont(ofSize: 14, weight: .regular)
        static let xsmall = UIFont.systemFont(ofSize: 10, weight: .regular)
        static let xxsmall = UIFont.systemFont(ofSize: 8, weight: .regular)
        
    }
    
    struct Bold {
        
        static let base = UIFont.systemFont(ofSize: 16, weight: .semibold)
        static let small = UIFont.systemFont(ofSize: 14, weight: .semibold)
        
    }
    
}
