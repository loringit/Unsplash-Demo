//
//  UnsplashService.swift
//  Unsplash-Demo
//
//  Created by Булат Якупов on 02.06.2023.
//

import Combine
import Foundation

protocol IUnsplashService: AnyObject {
    
    func getPhotos(page: Int, count: Int) -> AnyPublisher<[PhotoDTO], Error>
    func searchPhotos(query: String, page: Int, count: Int) -> AnyPublisher<PaginatedResponse<PhotoDTO>, Error>
    func likePhoto(id: String) -> AnyPublisher<PhotoDTO, Error>
    func dislikePhoto(id: String) -> AnyPublisher<PhotoDTO, Error>
    func getUserProfile() -> AnyPublisher<UserDTO, Error>
    
}

class UnsplashService: IUnsplashService {
    
    // MARK: - Private properties
    
    private let requestService: IRequestService
    
    // MARK: - Lifecycle
    
    init(requestService: IRequestService) {
        self.requestService = requestService
    }
    
    // MARK: - Public methods
    
    func getPhotos(page: Int, count: Int) -> AnyPublisher<[PhotoDTO], Error> {
        let url = requestService.serverURL
            .appendingPathComponent("search")
            .appendingPathComponent("photos")
        
        let request = Request(
            url: url,
            method: .get,
            headers: requestService.defaultHeader,
            parameters: ["page": page, "per_page": count],
            encoding: .none
        )
        
        return requestService.make(request: request)
    }
    
    func searchPhotos(query: String, page: Int, count: Int) -> AnyPublisher<PaginatedResponse<PhotoDTO>, Error> {
        let url = requestService.serverURL
            .appendingPathComponent("photos")
        
        let request = Request(
            url: url,
            method: .get,
            headers: requestService.defaultHeader,
            parameters: ["page": page, "per_page": count],
            encoding: .none
        )
        
        return requestService.make(request: request)
    }
    
    func likePhoto(id: String) -> AnyPublisher<PhotoDTO, Error>{
        let url = requestService.serverURL
            .appendingPathComponent("photos")
            .appendingPathComponent(id)
            .appendingPathComponent("like")
        
        let request = Request(
            url: url,
            method: .post,
            headers: requestService.defaultHeader,
            encoding: .none
        )
        
        return requestService.make(request: request)
    }
    
    func dislikePhoto(id: String) -> AnyPublisher<PhotoDTO, Error> {
        let url = requestService.serverURL
            .appendingPathComponent("photos")
            .appendingPathComponent(id)
            .appendingPathComponent("like")
        
        let request = Request(
            url: url,
            method: .delete,
            headers: requestService.defaultHeader,
            encoding: .none
        )
        
        return requestService.make(request: request)
    }
    
    func getUserProfile() -> AnyPublisher<UserDTO, Error> {
        let url = requestService.serverURL
            .appendingPathComponent("me")
        
        let request = Request(
            url: url,
            method: .get,
            headers: requestService.defaultHeader,
            encoding: .none
        )
        
        return requestService.make(request: request)
    }
    
}
