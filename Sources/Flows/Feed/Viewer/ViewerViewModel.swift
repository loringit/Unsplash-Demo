//
//  ViewerViewModel.swift
//  Unsplash-Demo
//
//  Created by Булат Якупов on 04.06.2023.
//

import Combine
import Foundation

enum ViewerViewModelOut {
    
    case back
    case share
    case info
    case download
    
}

protocol IViewerViewModel: AnyObject {
    
    // MARK: - Inputs
    
    var tapLikeSubject: AnySubject<Void, Never> { get }
    var tapDownloadSubject: AnySubject<Void, Never> { get }
    var tapInfoSubject: AnySubject<Void, Never> { get }
    var tapShareSubject: AnySubject<Void, Never> { get }
    var tapBackSubject: AnySubject<Void, Never> { get }
    
    // MARK: - Output
    
    var photoItemPublisher: AnyPublisher<PhotoItem, Error> { get }
 
}

class ViewerViewModel: IViewerViewModel {
    
    // MARK: - Public properties
    
    var out: ((ViewerViewModelOut) -> ())?
    
    // MARK: Inputs
    
    let tapLikeSubject = AnySubject<Void, Never>(PassthroughSubject())
    let tapDownloadSubject = AnySubject<Void, Never>(PassthroughSubject())
    let tapInfoSubject = AnySubject<Void, Never>(PassthroughSubject())
    let tapShareSubject = AnySubject<Void, Never>(PassthroughSubject())
    let tapBackSubject = AnySubject<Void, Never>(PassthroughSubject())
    
    // MARK: Output
    
    lazy var photoItemPublisher: AnyPublisher<PhotoItem, Error> = createPhotoItemPublisher()
    
    // MARK: - Private properties
    
    private let unsplashService: IUnsplashService
    private var currentItem: PhotoItem
    private var subscriptions = Set<AnyCancellable>()
    
    // MARK: - Lifecycle
    
    init(unsplashService: IUnsplashService, item: PhotoItem) {
        self.unsplashService = unsplashService
        self.currentItem = item
        self.bindInputs()
    }
    
    // MARK: - Private methods
    
    private func bindInputs() {
        tapBackSubject
            .sink(receiveValue: { [weak self] _ in
                self?.out?(.back)
            })
            .store(in: &subscriptions)
        
        tapDownloadSubject
            .sink(receiveValue: { [weak self] _ in
                self?.out?(.download)
            })
            .store(in: &subscriptions)
        
        tapInfoSubject
            .sink(receiveValue: { [weak self] _ in
                self?.out?(.info)
            })
            .store(in: &subscriptions)
        
        tapShareSubject
            .sink(receiveValue: { [weak self] _ in
                self?.out?(.share)
            })
            .store(in: &subscriptions)
    }
    
    func createPhotoItemPublisher() -> AnyPublisher<PhotoItem, Error> {
        return tapLikeSubject
            .map { [weak self] _ in
                guard let self else {
                    return Empty<PhotoItem, Error>().eraseToAnyPublisher()
                }
                
                if self.currentItem.isLiked {
                    return self.unsplashService
                        .dislikePhoto(id: self.currentItem.id)
                        .map { PhotoItem.mapFromDTO($0) }
                        .eraseToAnyPublisher()
                } else {
                    return self.unsplashService
                        .likePhoto(id: self.currentItem.id)
                        .map { PhotoItem.mapFromDTO($0) }
                        .eraseToAnyPublisher()
                }
            }
            .switchToLatest()
            .handleEvents(receiveOutput: { [weak self] output in
                self?.currentItem = output
            })
            .prepend(currentItem)
            .eraseToAnyPublisher()
    }
    
}
