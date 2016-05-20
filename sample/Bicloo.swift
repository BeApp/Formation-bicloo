//
//  Bicloo.swift
//  sample
//
//  Created by Cedric G on 17/05/2016.
//  Copyright © 2016 Cedric G. All rights reserved.
//

import Foundation
import MapKit

class Bicloo: NSObject {
    
    var number: Int = 0
    var name: String
    var address: String
    var lat: Double = 0
    var lon: Double = 0
    
    var distance: Double = -1
    var location: CLLocation {
        get {
            return CLLocation.init(latitude: lat, longitude: lon)
        }
    }
    
    //MARK: - Init
    init(raw:Dictionary<String, AnyObject>) {
        self.name = raw["name"] as? String ?? ""
        self.address = raw["address"] as? String ?? ""
        if let n = raw["number"] as? NSNumber {
            self.number = Int(n)
        }
        if let pos = raw["position"] as? Dictionary<String, AnyObject> {
            if let lat = pos["lat"] as? NSNumber {
                self.lat = Double(lat)
            }
            if let lon = pos["lng"] as? NSNumber {
                self.lon = Double(lon)
            }
        }
    }
    
    init(number: Int, name: String, address: String, lat: Double, lon: Double) {
        self.number = number
        self.name = name
        self.address = address
        self.lat = lat
        self.lon = lon
        super.init()
    }
    
    required convenience init?(coder decoder: NSCoder) {
        guard let number = decoder.decodeObjectForKey("number") as? Int,
            let name = decoder.decodeObjectForKey("name") as? String,
            let address = decoder.decodeObjectForKey("address") as? String,
            let lat = decoder.decodeObjectForKey("lat") as? Double,
            let lon = decoder.decodeObjectForKey("lon") as? Double
            else {
                return nil
        }
        self.init(number: number, name: name, address: address, lat: lat, lon: lon)
    }
    
    //MARK: - Static
    static func saveBicloos(velos: [Bicloo]) {
        NSKeyedArchiver.archiveRootObject(velos, toFile: getPath())
    }
    
    static func getBicloos() -> [Bicloo] {
        guard let velos = NSKeyedUnarchiver.unarchiveObjectWithFile(getPath()) as? [Bicloo] else {
            return []
        }
        return velos
    }
    
    static func getPath() -> String {
        let manager = NSFileManager.defaultManager()
        let url = manager.URLsForDirectory(.CachesDirectory, inDomains: .UserDomainMask).first!
        return url.URLByAppendingPathComponent("Bicloo").path!
    }
    
}

// MARK: - NSCoding
extension Bicloo: NSCoding {
    func encodeWithCoder(coder: NSCoder) {
        coder.encodeObject(self.number, forKey: "number")
        coder.encodeObject(self.name, forKey: "name")
        coder.encodeObject(self.address, forKey: "address")
        coder.encodeObject(self.lat, forKey: "lat")
        coder.encodeObject(self.lon, forKey: "lon")
    }
}

//MARK: - MKAnnotation
extension Bicloo: MKAnnotation {
    var coordinate: CLLocationCoordinate2D {
        get {
            return CLLocationCoordinate2DMake(lat, lon)
        }
    }
    var title: String? {
        get {
            return name
        }
    }
    var subtitle: String? {
        get {
            return address
        }
    }
}

