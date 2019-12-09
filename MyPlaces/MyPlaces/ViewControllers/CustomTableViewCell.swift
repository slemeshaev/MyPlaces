//
//  CustomTableViewCell.swift
//  MyPlaces
//
//  Created by Станислав Лемешаев on 01/10/2019.
//  Copyright © 2019 Станислав Лемешаев. All rights reserved.
//

import UIKit

class CustomTableViewCell: UITableViewCell {
    @IBOutlet weak var imageOfPlace: UIImageView! {
        didSet {
            imageOfPlace.layer.cornerRadius = imageOfPlace.frame.size.height / 2
            imageOfPlace.clipsToBounds = true
        }
    }
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var ratingView: RatingControl! {
        didSet {
            // Проблема с багом не решена 
            //ratingView.settings.updateOnTouch = false
        }
    }
    
    func configureCell(place: Place) {
        nameLabel.text = place.name
        locationLabel.text = place.location
        typeLabel.text = place.type
        imageOfPlace.image = UIImage(data: place.imageData!)
        ratingView.rating = place.rating
    }
}
