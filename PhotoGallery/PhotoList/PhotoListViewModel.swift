//
//  PhotoListViewModel.swift
//  Photo Gallery
//
//  Created by Andrea on 27/02/2018.
//  Copyright © 2018 Andrea Stevanato. All rights reserved.
//

import Foundation

class PhotoListViewModel {

    // MARK: Properties

    let apiService: PhotoServiceProtocol

    private var photos: [Photo] = [Photo]()

    private var cellViewModels: [PhotoListCellViewModel] = [PhotoListCellViewModel]() {
        didSet {
            self.reloadTableViewClosure?()
        }
    }

    var isLoading: Bool = false {
        didSet {
            self.updateLoadingStatus?()
        }
    }

    var alertMessage: String? {
        didSet {
            self.showAlertClosure?()
        }
    }

    var numberOfCells: Int {
        return cellViewModels.count
    }

    var isAllowSegue: Bool = false
    var selectedPhoto: Photo?

    // MARK: Closures

    var reloadTableViewClosure: (() -> Void)?
    var showAlertClosure: (() -> Void)?
    var updateLoadingStatus: (() -> Void)?

    // MARK: Methods

    init( apiService: PhotoServiceProtocol = PhotoService()) {
        self.apiService = apiService
    }

    func initFetch() {
        self.isLoading = true
        apiService.fetchPopularPhoto { [weak self] (_, photos, error) in
            self?.isLoading = false
            if let error = error {
                self?.alertMessage = error.rawValue
            } else {
                self?.processFetchedPhoto(photos: photos)
            }
        }
    }

    func getCellViewModel( at indexPath: IndexPath ) -> PhotoListCellViewModel {
        return cellViewModels[indexPath.row]
    }

    func createCellViewModel(photo: Photo) -> PhotoListCellViewModel {

        var descTextContainer: [String] = [String]()
        if let camera = photo.camera {
            descTextContainer.append(camera)
        }
        if let description = photo.description {
            descTextContainer.append( description )
        }
        let desc = descTextContainer.joined(separator: " - ")

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        return PhotoListCellViewModel(titleText: photo.name,
                                      descText: desc,
                                      imageUrl: photo.imageUrl,
                                      dateText: dateFormatter.string(from: photo.createdAt) )
    }

    private func processFetchedPhoto( photos: [Photo] ) {
        self.photos = photos // Cache
        var viewModels = [PhotoListCellViewModel]()
        for photo in photos {
            viewModels.append( createCellViewModel(photo: photo) )
        }
        self.cellViewModels = viewModels
    }

    func userPressed( at indexPath: IndexPath ) {
        let photo = self.photos[indexPath.row]
        if photo.forSale {
            self.isAllowSegue = true
            self.selectedPhoto = photo
        } else {
            self.isAllowSegue = false
            self.selectedPhoto = nil
            self.alertMessage = "This item is not for sale"
        }
    }
}
