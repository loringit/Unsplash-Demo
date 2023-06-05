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
        
    func tapLike()
    func tapDownload()
    func tapInfo()
    func tapShare()
    func tapBack()
    
    var photoItem: PhotoItem { get }
    var isLikedPublisher: AnyPublisher<Bool, Error> { get }
 
}

class ViewerViewModel: IViewerViewModel {
    
    // MARK: - Public properties
    
    var out: ((ViewerViewModelOut) -> ())?
            
    lazy var isLikedPublisher: AnyPublisher<Bool, Error> = isLikedSubject.eraseToAnyPublisher()
    @Atomic var photoItem: PhotoItem
    
    // MARK: - Private properties
    
    private let isLikedSubject: CurrentValueSubject<Bool, Error>
    private let unsplashService: IUnsplashService
    private var subscriptions = Set<AnyCancellable>()
    
    // MARK: - Lifecycle
    
    init(unsplashService: IUnsplashService, item: PhotoItem) {
        self.unsplashService = unsplashService
        self.photoItem = item
        self.isLikedSubject = CurrentValueSubject(item.isLiked)
    }
    
    // MARK: - Public methods
    
    func tapLike() {
        let publisher: AnyPublisher<LikeDTO, Error>
        
        if photoItem.isLiked {
            publisher = unsplashService.dislikePhoto(id: photoItem.id)
        } else {
            publisher = unsplashService.likePhoto(id: photoItem.id)
        }
        
        photoItem.isLiked.toggle()
        isLikedSubject.send(photoItem.isLiked)
        
        publisher
            .sink { [weak self] result in
                self?.isLikedSubject.send(completion: result)
            } receiveValue: { [weak self] dto in
                self?.photoItem.isLiked = dto.photo.likedByUser
            }
            .store(in: &subscriptions)
    }
    
    func tapDownload() {
        out?(.download)
    }
    
    func tapInfo() {
        out?(.info)
    }
    
    func tapShare() {
        out?(.share)
    }
    
    func tapBack() {
        out?(.back)
    }
    
}
