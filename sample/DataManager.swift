//
//  DataManager.swift
//  sample
//
//  Created by Cedric G on 18/05/2016.
//  Copyright © 2016 Cedric G. All rights reserved.
//

import Foundation
import Alamofire
import CoreLocation

class DataManager: NSObject {

    var datas: [Bicloo] = []
    
    var currentLocation: CLLocation?
    let locationManager = CLLocationManager()
    
    //MARK: - Life
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
    }

    // MARK: - shared
    
    class var sharedData : DataManager {
        struct Static {
            static let instance = DataManager()
        }
        return Static.instance
    }
    
    // MARK: - Data
    
    func loadData(done callback:()->()) {
        let params = ["contract":"Nantes","apiKey":""]
        Alamofire.request(.GET, "https://api.jcdecaux.com/vls/v1/stations", parameters: params)
            .validate()
            .responseJSON { response in
                switch response.result {
                case .Success:
                    guard let datas = response.result.value as? [AnyObject] else {
                        return
                    }
                    var velos: [Bicloo] = []
                    for data in datas {
                        let velo = Bicloo(raw: data as! Dictionary<String, AnyObject>)
                        velos.append(velo)
                    }
                    self.datas = velos
                    Bicloo.saveBicloos(velos)
                    callback()
                case .Failure(let error):
                    print(error)
                }
        }
    }
}


// MARK: - CLLocationManagerDelegate
extension DataManager: CLLocationManagerDelegate {
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .AuthorizedWhenInUse || status == .AuthorizedAlways {
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations.first
    }
}

