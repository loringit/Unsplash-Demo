//
//  FeedViewModel.swift
//  Unsplash-Demo
//
//  Created by Булат Якупов on 03.06.2023.
//

import Combine
import Foundation
import OrderedCollections

enum FeedViewModelOut {
    
    case open(FeedItem)
    
}

protocol IFeedViewModel: AnyObject {
    
    // MARK: - Inputs
    
    var querySubject: AnySubject<String?, Never> { get }
    var tapSubject: AnySubject<FeedItem, Never> { get }
    var nextPageSubject: AnySubject<Void, Never> { get }
    
    // MARK: - Outputs
    
    var photosPublisher: AnyPublisher<[FeedItem], Error> { get }
    var refreshLayoutPublisher: AnyPublisher<Void, Never> { get }
    
}


class FeedViewModel: IFeedViewModel {
    
    // MARK: - Public properties
    
    var out: ((FeedViewModelOut) -> ())?
    
    // MARK: Inputs
    
    lazy var querySubject: AnySubject<String?, Never> = {
        .init(queryValueSubject)
    }()
    let tapSubject = AnySubject<FeedItem, Never>(PassthroughSubject())
    let nextPageSubject = AnySubject<Void, Never>(PassthroughSubject())
    
    // MARK: Outputs
    
    lazy var photosPublisher: AnyPublisher<[FeedItem], Error> = {
        createPhotosPublisher()
    }()
    
    lazy var refreshLayoutPublisher: AnyPublisher<Void, Never> = {
        .init(refreshLayoutSubject)
    }()
    
    // MARK: - Private properties
    
    private let unsplashService: IUnsplashService
    private var subscriptions = Set<AnyCancellable>()
    private let queryValueSubject = CurrentValueSubject<String?, Never>(nil)
    private let refreshLayoutSubject = PassthroughSubject<Void, Never>()
    private var oldQuery: String?
    private var currentItems: OrderedSet<FeedItem> = OrderedSet()
    
    private lazy var editorFeedFetcher: PageBasedFetcher<FeedItem> = {
        PageBasedFetcher(count: 20, loader: { [weak self] (count, page) -> (AnyPublisher<[FeedItem], Error>)? in
            guard let self = self else { return nil }
            
            return self.unsplashService.getPhotos(page: page, count: count)
                .map{ $0.map { FeedViewModel.mapToFeedItem($0) } }
                .eraseToAnyPublisher()
        })
    }()
    
    private lazy var searchFetcher: PageBasedFetcher<FeedItem> = {
        PageBasedFetcher(count: 20, loader: { [weak self] (count, page) -> (AnyPublisher<[FeedItem], Error>)? in
            guard let self = self, let query = self.queryValueSubject.value, !query.isEmpty else { return nil }
            
            return self.unsplashService.searchPhotos(query: query, page: page, count: count)
                .map { $0.results.map { FeedViewModel.mapToFeedItem($0) } }
                .eraseToAnyPublisher()
        })
    }()
    
    // MARK: - Lifecycle
    
    init(unsplashService: IUnsplashService) {
        self.unsplashService = unsplashService
        self.bindInputs()
    }
    
    // MARK: - Private properties
    
    private func bindInputs() {
        nextPageSubject
            .sink { [weak self] _ in
                guard let self else { return }
                
                let query = self.queryValueSubject.value
                
                if query != nil, query != "" {
                    if self.oldQuery == nil || self.oldQuery == "" || self.oldQuery != query {
                        self.searchFetcher.reset()
                        self.currentItems.removeAll()
                        self.refreshLayoutSubject.send()
                    }
                    self.searchFetcher.loadNext()
                } else {
                    if self.oldQuery != nil, self.oldQuery != "" {
                        self.editorFeedFetcher.reset()
                        self.currentItems.removeAll()
                        self.refreshLayoutSubject.send()
                    }
                    self.editorFeedFetcher.loadNext()
                }
            }
            .store(in: &subscriptions)
        
        tapSubject
            .sink(receiveValue: { [weak self] feedItem in
                self?.out?(.open(feedItem))
            })
            .store(in: &subscriptions)
    }
    
    private func createPhotosPublisher() -> AnyPublisher<[FeedItem], Error> {
        return queryValueSubject
            .throttle(for: 0.3, scheduler: RunLoop.main, latest: true)
            .map { [weak self] query in
                guard let self else {
                    return Empty<[FeedItem], Error>().eraseToAnyPublisher()
                }
                
                defer {
                    self.oldQuery = query
                }
                
                if query != nil, query != "" {
                    return self.searchFetcher.loadedNext
                } else {
                    return self.editorFeedFetcher.loadedNext
                }
            }
            .switchToLatest()
            .map { [weak self] items in
                guard let self else {
                    return items
                }
                
                self.currentItems.append(contentsOf: items)
                return [FeedItem](self.currentItems)
            }
            .eraseToAnyPublisher()
    }
    
    private static func mapToFeedItem(_ dto: PhotoDTO) -> FeedItem {
        let properties = [
            "Make": dto.exif?.make ?? "-",
            "Model": dto.exif?.model ?? "-",
            "Shutter speed": dto.exif?.exposureTime ?? "-",
            "Aperture": dto.exif?.aperture ?? "-",
            "Focal Length": dto.exif?.focalLenght ?? "-",
            "ISO": dto.exif?.iso != nil ? "\(dto.exif!.iso)" : "-",
            "Dimensions": "\(dto.width) x \(dto.height)"
        ]
        
        return FeedItem(
            id: dto.id,
            ratio: CGFloat(dto.width) / CGFloat(dto.height),
            description: dto.description,
            altDescription: dto.altDescription,
            fullURL: dto.urls.full,
            smallURL: dto.urls.small,
            shareURL: dto.links.html,
            downloadURL: dto.links.download,
            properties: properties,
            isLiked: dto.likedByUser,
            user: ShortUser(
                id: dto.user.id,
                name: "\(dto.user.firstName ?? "") \(dto.user.lastName ?? "")",
                profileImageURL: dto.user.profileImage.medium
            )
        )
    }
    
}
