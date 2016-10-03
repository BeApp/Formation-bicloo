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
        guard let number = decoder.decodeObject(forKey: "number") as? Int,
            let name = decoder.decodeObject(forKey: "name") as? String,
            let address = decoder.decodeObject(forKey: "address") as? String,
            let lat = decoder.decodeObject(forKey: "lat") as? Double,
            let lon = decoder.decodeObject(forKey: "lon") as? Double
            else {
                return nil
        }
        self.init(number: number, name: name, address: address, lat: lat, lon: lon)
    }
    
    //MARK: - Static
    static func saveBicloos(_ velos: [Bicloo]) {
        NSKeyedArchiver.archiveRootObject(velos, toFile: getPath())
    }
    
    static func getBicloos() -> [Bicloo] {
        guard let velos = NSKeyedUnarchiver.unarchiveObject(withFile: getPath()) as? [Bicloo] else {
            return []
        }
        return velos
    }
    
    static func getPath() -> String {
        let manager = FileManager.default
        let url = manager.urls(for: .cachesDirectory, in: .userDomainMask).first!
        return url.appendingPathComponent("Bicloo").path
    }
    
}

// MARK: - NSCoding
extension Bicloo: NSCoding {
    func encode(with coder: NSCoder) {
        coder.encode(self.number, forKey: "number")
        coder.encode(self.name, forKey: "name")
        coder.encode(self.address, forKey: "address")
        coder.encode(self.lat, forKey: "lat")
        coder.encode(self.lon, forKey: "lon")
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

