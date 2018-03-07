//
//  Photo.swift
//  Photo Gallery
//
//  Created by Andrea on 27/02/2018.
//  Copyright © 2018 Andrea Stevanato. All rights reserved.
//

import Foundation

struct Photos: Codable {
    let photos: [Photo]
}

struct Photo: Codable {

    enum CodingKeys: String, CodingKey {
        case identifier = "id"
        case name
        case description
        case createdAt = "created_at"
        case imageUrl = "image_url"
        case forSale = "for_sale"
        case camera
    }

    let identifier: Int
    let name: String
    let description: String?
    let createdAt: Date
    let imageUrl: String
    let forSale: Bool
    let camera: String?
}
