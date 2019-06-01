//
//  PhotoCell.swift
//  Virtual Tourist
//
//  Created by Reem on 5/26/19.
//  Copyright © 2019 Udacity. All rights reserved.
//

import Foundation
import UIKit

class PhotoCell: UICollectionViewCell {
    
    static let id = "SentCollectionViewCell"
    
    var photoUrl: String = ""
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
}
