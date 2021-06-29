//
//  PlaceModel.swift
//  MyPlaces
//
//  Created by Nikita Gribin on 29.06.2021.
//

import Foundation


struct Place {
    var name: String
    var location: String
    var type: String
    var image: String
    
    
 static   let restaurantNames = [
        "Burger Heroes", "Kitchen", "Bonsai", "Дастархан",
        "Индокитай", "X.O", "Балкан Гриль", "Sherlock Holmes",
        "Speak Easy", "Morris Pub", "Вкусные истории",
        "Классик", "Love&Life", "Шок", "Бочка"
    ]
    
   static func getPlaces() -> [Place] {
        
    var places = [Place]()
        
        for place in restaurantNames {
            places.append(Place(name: place, location: "Moscow", type: "Restuarnt", image: place))
        }
        
        return places
    }
}
