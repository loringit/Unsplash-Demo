//
//  ReuqestProgress.swift
//  Unsplash-Demo
//
//  Created by Булат Якупов on 02.06.2023.
//

import Foundation

struct RequestProgress {
    
    var progress: Double
    var totalSize: Int64
    var finished: Bool
    var error: Error?
    var url: URL?
    
}
