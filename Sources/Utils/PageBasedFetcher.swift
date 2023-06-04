//
//  PageBasedFetcher.swift
//  Unsplash-Demo
//
//  Created by Булат Якупов on 04.06.2023.
//

import Combine
import Foundation

final class PageBasedFetcher<Element> {
    
    typealias LoaderType = (Int, Int) -> (AnyPublisher<[Element], Error>)?
    
    // MARK: - Public properties
    
    var loadedNext: AnyPublisher<[Element], Error>!
    let count: Int
    private(set) var page: Int = 0
    private(set) var isDownloading = false
    
    // MARK: - Private properties
    
    private let loadNextSubject = CurrentValueSubject<Void, Never>(())
    private let loader: LoaderType
    
    // MARK: - Lifecycle
    
    public init(page: Int = 0, count: Int = 50, loader: @escaping LoaderType) {
        self.page = page
        self.count = count
        self.loader = loader
        
        loadedNext = loadNextSubject
            .filter { [weak self] _ in
                return self?.isDownloading == false
            }
            .eraseToAnyPublisher()
            .map { [weak self] _ in
                guard let self, let loader = self.loader(self.count, self.page) else { return Empty<[Element], Error>().eraseToAnyPublisher() }
                
                return loader.handleEvents(
                    receiveOutput: { [weak self] (justReceived: [Element]) in
                        guard let self = self else { return }
                                                
                        if justReceived.count == self.count {
                            self.page += 1
                        }
                        self.isDownloading = false
                    },
                    receiveCompletion: { [weak self] result in
                        guard let self = self else { return }
                        
                        switch result {
                        case .finished:
                            self.isDownloading = false
                        case .failure(let error):
                            self.isDownloading = false
                            print("\(#fileID) \(#line): \(error)")
                        }
                    }
                )
                .eraseToAnyPublisher()
            }
            .switchToLatest()
            .eraseToAnyPublisher()
    }
    
    // MARK: - Public methods
    
    public func loadNext() {
        loadNextSubject.send(())
    }
    
    public func reset() {
        page = 0
    }
    
}
