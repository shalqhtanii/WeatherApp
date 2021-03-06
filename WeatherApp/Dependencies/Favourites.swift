//
//  Favourties.swift
//  Weather App
//
//  Created by Krzysztof Podolak on 03/03/2019.
//  Copyright © 2019 Krzysztof Podolak. All rights reserved.
//

import Foundation
import CoreLocation
import UIKit
import MobileCoreServices

class Favourites: FavouritesProtocol {
    internal var items: [Location] = []
    var filePath = ""
    var fileName = "favourites.json"
    var locationManager: CLLocationManager!
    var count: Int {
        return self.items.count
    }
    
    var timeStamp: String {
        let dateFormatter = DateFormatter()
        let now = Date()
        
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSSS"
        
        return dateFormatter.string(from: now)
    }
    
    func delete(id: Int, commit: Bool) -> Void {
        if let itemToDelete = items.first(where: { l in
            return l.id == id ? true : false
        }), let indexOfItemToDelete = items.index(of: itemToDelete) {
            items.remove(at: indexOfItemToDelete)
            
            if commit == true {
                self.save()
            }
        }
    }

    func insert(_ newLocation: Location, at index: Int) {
        let alreadyInFavourties = items.contains(newLocation)
        
        if !alreadyInFavourties {
            items.insert(newLocation, at: index)
        }
    }
    
    func delete(at index: Int, commit: Bool = false) -> Void {
        if index > items.count || index < 0 {
            return
        }
        
        items.remove(at: index)
        if commit == true {
            self.save()
        }
    }
    
    init(_ dir : String) {
        filePath = dir + "/" + fileName
    }
    
    func save() {
        let encoder = JSONEncoder()
        
        encoder.outputFormatting = .prettyPrinted
        
        let encoded = try? encoder.encode(items)
        
        if FileManager.default.fileExists(atPath: filePath) {
            if let file = FileHandle(forWritingAtPath: filePath) {
                file.truncateFile(atOffset: 0)
                file.write(encoded!)
                file.closeFile()
            }
        }
        else {
            FileManager.default.createFile(atPath: filePath, contents: encoded!, attributes: nil)
        }
        
        print("\(self.timeStamp); \(type(of: self)); \(#function); Saved at \(fileName)...")
    }
    
    func load() {
        let decoder = JSONDecoder()
        
        print("\(self.timeStamp); \(type(of: self)); \(#function); Attempting to load favourties from \(fileName)...")
        
        if FileManager.default.fileExists(atPath: filePath) {
            if let file = FileHandle(forReadingAtPath: filePath) {
                let data = file.readDataToEndOfFile()
                let favourites = try? decoder.decode([Location].self, from: data)
                self.items = favourites ?? []
                file.closeFile()
            }
        }
        else
        {
            save()
        }
    }
    
    func add(_ newLocation: Location) {
        let alreadyInFavourties = items.contains(newLocation)
        
        if !alreadyInFavourties {
            items.append(newLocation)
        }
    }
    
    func swapAt(_ a: Int, _ b: Int) {
        self.items.swapAt(a, b)
    }
    
    subscript(index: Int) -> Location? {
        let outOfRange = index < 0 || index > self.count
        
        guard !outOfRange else {
            return nil
        }
        
        let l = self.items[index]
        
        return l
    }
}
