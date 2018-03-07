//
//  MockPhotoService.swift
//  Photo GalleryTests
//
//  Created by Andrea on 27/02/2018.
//  Copyright © 2018 Andrea Stevanato. All rights reserved.
//

import Foundation
@testable import PhotoGallery

class MockPhotoService: PhotoServiceProtocol {

    var isFetchPopularPhotoCalled = false

    var completePhotos: [Photo] = [Photo]()
    var completeClosure: ((Bool, [Photo], APIError?) -> ())!

    func fetchPopularPhoto(complete: @escaping (Bool, [Photo], APIError?) -> ()) {
        isFetchPopularPhotoCalled = true
        completeClosure = complete
    }

    func fetchSuccess() {
        completeClosure( true, completePhotos, nil )
    }

    func fetchFail(error: APIError?) {
        completeClosure( false, completePhotos, error )
    }
}
