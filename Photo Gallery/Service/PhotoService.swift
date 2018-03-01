//
//  PhotoService.swift
//  Photo Gallery
//
//  Created by Andrea on 27/02/2018.
//  Copyright © 2018 Andrea Stevanato. All rights reserved.
//

import Foundation

enum APIError: String, Error {
    case noNetwork = "No Network"
    case serverOverload = "Server is overloaded"
    case permissionDenied = "You don't have permission"
}

protocol PhotoServiceProtocol {
    func fetchPopularPhoto( complete: @escaping ( _ success: Bool, _ photos: [Photo], _ error: APIError? ) -> Void )
}

class PhotoService: PhotoServiceProtocol {

    func fetchPopularPhoto( complete: @escaping ( _ success: Bool, _ photos: [Photo], _ error: APIError? ) -> Void ) {
        DispatchQueue.global().async {
            sleep(3)
            let path = Bundle.main.path(forResource: "data", ofType: "json")!
            let data = try? Data(contentsOf: URL(fileURLWithPath: path))
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let photos = try? decoder.decode(Photos.self, from: data!)
            complete( true, photos!.photos, nil )
        }
    }

}
