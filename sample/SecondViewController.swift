//
//  SecondViewController.swift
//  sample
//
//  Created by Cedric G on 17/05/2016.
//  Copyright © 2016 Cedric G. All rights reserved.
//

import UIKit
import MapKit
import FBAnnotationClusteringSwift

class SecondViewController: UIViewController {
    
    var items: [Bicloo] = []
    
    @IBOutlet weak var mapView: MKMapView!
    
    let clusteringManager = FBClusteringManager()
    
    // MARK: - Life
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        DataManager.sharedData.loadData {
            self.loadFromManager()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func loadFromManager() {
        items = DataManager.sharedData.datas
        clusteringManager.addAnnotations(items)
        clusteringManager.delegate = self;
    }
}

//MARK: - FBClusteringManagerDelegate
extension SecondViewController : FBClusteringManagerDelegate {
    func cellSizeFactorForCoordinator(coordinator:FBClusteringManager) -> CGFloat{
        return 1.0
    }
}

//MARK: - MKMapViewDelegate
extension SecondViewController: MKMapViewDelegate {
    
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool){
        NSOperationQueue().addOperationWithBlock({
            let mapBoundsWidth = Double(self.mapView.bounds.size.width)
            let mapRectWidth:Double = self.mapView.visibleMapRect.size.width
            let scale:Double = mapBoundsWidth / mapRectWidth
            let annotationArray = self.clusteringManager.clusteredAnnotationsWithinMapRect(self.mapView.visibleMapRect, withZoomScale:scale)
            self.clusteringManager.displayAnnotations(annotationArray, onMapView:self.mapView)
        })
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation.isKindOfClass(FBAnnotationCluster) {
            let reuseId = "Cluster"
            var clusterView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? FBAnnotationClusterView
            clusterView?.annotation = annotation
            if clusterView == nil {
                clusterView = FBAnnotationClusterView(annotation: annotation, reuseIdentifier: reuseId, options: nil)
            }
            return clusterView
        }
        else {
            let reuseId = "Pin"
            var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
            if pinView == nil {
                pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
                pinView?.pinTintColor = UIColor.orangeColor()
                pinView?.canShowCallout = true
            }
            return pinView
        }
    }
    
    
    
}

