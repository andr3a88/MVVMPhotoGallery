//
//  PhotoDetailViewController.swift
//  Photo Gallery
//
//  Created by Andrea on 27/02/2018.
//  Copyright © 2018 Andrea Stevanato. All rights reserved.
//

import Foundation
import SDWebImage

class PhotoDetailViewController: UIViewController {

    // MARK: IBOutlets

    @IBOutlet weak var imageView: UIImageView!

    // MARK: Properties

    var imageUrl: String?

    // MARK: Methods

    override func viewDidLoad() {
        super.viewDidLoad()

        self.loadImage()
    }

    private func loadImage() {
        guard let imageUrl = imageUrl else { return }
        imageView.sd_setImage(with: URL(string: imageUrl))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
