//
//  DownloadImagePresenter.swift
//  Unsplash-Demo
//
//  Created by Булат Якупов on 05.06.2023.
//

import Combine
import Foundation
import Nuke
import UIKit

enum DownloadViewModelOut {
    
    case finished
    
}

protocol IDownloadViewModel {
    
    var actionTitle: String { get }
    var resultTitle: String { get }
    var downloadProgressPublisher: AnyPublisher<(Double, Int64), Error> { get }
    
}

class DownloadViewModel: IDownloadViewModel {
    
    // MARK: - Public properties
    
    var out: ((DownloadViewModelOut) -> ())?
    
    let actionTitle = "Downloading"
    var resultTitle = "Image saved in Photos"
    lazy var downloadProgressPublisher: AnyPublisher<(Double, Int64), Error> = {
        downloadSubject.eraseToAnyPublisher()
    }()
    
    // MARK: - Private properties
    
    private let downloadSubject = PassthroughSubject<(Double, Int64), Error>()
    private let item: PhotoItem
    
    // MARK: - Lifecycle
    
    init(item: PhotoItem) {
        self.item = item
        
        let request = ImageRequest(url: item.downloadURL)
        if let container = ImagePipeline.shared.cache.cachedImage(for: request) {
            downloadSubject.send((1.0, 0))
            UIImageWriteToSavedPhotosAlbum(container.image, nil, nil, nil)
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
                self?.out?(.finished)
            }
        } else {
            let imageTask = ImagePipeline.shared.loadImage(
                with: request,
                progress: { [weak self] response, completed, total in
                    self?.downloadSubject.send((Double(completed) / Double(total), total))
                },
                completion: { [weak self] result in
                    do {
                        let image = try result.get().image
                        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                    } catch {
                        print("\(#file) \(#line): \(error)")
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        self?.out?(.finished)
                    }
                }
            )
        }
    }
    
}
