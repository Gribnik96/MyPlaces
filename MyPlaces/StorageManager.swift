//
//  StorageManager.swift
//  MyPlaces
//
//  Created by Nikita Gribin on 03.07.2021.
//

import RealmSwift

let realm = try! Realm()

class StorageManager {
    static func saveObject(_ place: Place) {
        try! realm.write {
            realm.add(place)
        }
    }
    
    static func  deleteObject(_ place: Place) {
        try! realm.write {
            realm.delete(place)
        }
    }
}
