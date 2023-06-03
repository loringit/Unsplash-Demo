//
//  ColorScheme.swift
//  Unsplash-Demo
//
//  Created by Булат Якупов on 03.06.2023.
//

import UIKit

extension UIColor {
    
    struct Backgroud {
        
        static let primary = UIColor(named: "BackgroundPrimary")
        static let secondary = UIColor(named: "BackgroundSecondary")
        
    }
    
    struct Button {
        
        static let primary = UIColor(named: "ButtonPrimary")
        static let secondary = UIColor(named: "ButtonSecondary")
        static let danger = UIColor(named: "ButtonDanger")
        
    }
    
    struct Text {
        
        static let primary = UIColor(named: "TextPrimary")
        static let secondary = UIColor(named: "TextSecondary")
        static let danger = UIColor(named: "TextDanger")
        
    }
    
    struct TabBar {
        
        static let selected = UIColor(named: "TabSelected")!
        static let unselected = UIColor(named: "TabUnselected")!
        static let background = UIColor(named: "TabBackground")!
        
    }
    
    var dark: UIColor  { resolvedColor(with: .init(userInterfaceStyle: .dark))  }
    var light: UIColor { resolvedColor(with: .init(userInterfaceStyle: .light)) }
    
}
