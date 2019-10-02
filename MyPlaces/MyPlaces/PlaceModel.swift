//
//  PlaceModel.swift
//  MyPlaces
//
//  Created by Станислав Лемешаев on 01/10/2019.
//  Copyright © 2019 Станислав Лемешаев. All rights reserved.
//

import UIKit

struct Place {
    
    var name: String
    var location: String?
    var type: String?
    var image: UIImage?
    var restaurantImage: String?
    
    static let restaurantNames = [
        "Burger Heroes", "Kitchen", "Bonsai",
        "Балкан Гриль", "Вкусные истории",
        "Пятница", "Классик", "Шок", "Бочка"
    ]
    
    static func getPlaces() -> [Place] {
        var places = [Place]()
        
        for place in restaurantNames {
            places.append(Place(name: place, location: "Москва", type: "Ресторан", image: nil, restaurantImage: place))
        }
        
        return places
    }
    
}
