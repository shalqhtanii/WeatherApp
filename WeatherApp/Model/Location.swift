//
//  Location.swift
//  Weather App
//
//  Created by Krzysztof Podolak on 09/12/2018.
//  Copyright © 2018 Krzysztof Podolak. All rights reserved.
//

import Foundation
import CoreLocation
import MobileCoreServices

final class Location: NSObject, Codable {
    var city: String = "unknown"
    var country: String = "unknown"
    var countryCode: String?
    var id: Int = Int.min
    var latitude: Double = 0.00
    var longitude: Double = 0.00
    var name: String = "unknown"
    var region: String?
    var regionCode: String?
    var type: String?
    var wikiDataId: String?
    var timeZoneId: String?
    
    override init() {
        super.init()
    }
    
    init(jsonData: [String:Any]) {
        super.init()
        
        self.city = jsonData["name"] as? String ?? "unknown"
        self.region = jsonData["region"] as? String
        self.country = jsonData["country"] as? String ?? "unknown"
        self.id = jsonData["id"] as? Int ?? Int.min
        self.longitude = jsonData["longitude"] as? Double ?? 0.00
        self.latitude = jsonData["latitude"] as? Double ?? 0.00
        
        updateTimeZoneId { return }
    }
    
    func updateTimeZoneId(_ completionHandler: @escaping () -> Void) {
        let gc = CLGeocoder()
        
        let location = CLLocation(latitude: CLLocationDegrees(self.latitude), longitude: CLLocationDegrees(self.longitude))
        
        gc.reverseGeocodeLocation(location, completionHandler: { placemarks, error in
            if let placemarks = placemarks {
                let placemark = placemarks[0]
                self.timeZoneId = placemark.timeZone?.identifier
                
                completionHandler()
            }
        })
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let location = object as? Location else {
            return false
        }
        
        let rc = (self.city == location.city && self.country == location.country && self.region == location.region) || self.id == location.id
        
        return rc
    }
}

extension Location: NSItemProviderReading {
    static var readableTypeIdentifiersForItemProvider: [String] {
        return [kUTTypeData as String]
    }
    
    static func object(withItemProviderData data: Data, typeIdentifier: String) throws -> Location {
        let decoder = JSONDecoder()
        
        do {
            return try decoder.decode(Location.self, from: data)
        } catch {
            fatalError("Cannot decode Location while dropping...")
        }
    }
}

extension Location: NSItemProviderWriting {
    static var writableTypeIdentifiersForItemProvider: [String] {
        return [kUTTypeData as String]
    }
    
    func loadData(withTypeIdentifier typeIdentifier: String, forItemProviderCompletionHandler completionHandler: @escaping (Data?, Error?) -> Void) -> Progress? {
        let encoder = JSONEncoder()
        
        do {
            let data = try encoder.encode(self)
            completionHandler(data, nil)
        } catch {
            completionHandler(nil, error)
        }
        
        return nil
    }
}
