//
//  FirstViewController.swift
//  sample
//
//  Created by Cedric G on 17/05/2016.
//  Copyright © 2016 Cedric G. All rights reserved.
//

import UIKit
import MessageUI

//MARK: - Protocol 

protocol BiclooCellDelegate: class  {
    func didShareBicloo(velo: Bicloo)
    func didOpenMapBicloo(velo: Bicloo)
    func didSearchBicloo(velo: Bicloo)
}

//MARK: -

class FirstViewController: UIViewController {
    
    var sortByDistance = false
    var items: [Bicloo] = []
    
    var refreshControl = UIRefreshControl()
    @IBOutlet weak var myTableView: UITableView!
    
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    
    //MARK: - Life 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        myTableView.rowHeight = UITableViewAutomaticDimension
        myTableView.estimatedRowHeight = 100
        
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(FirstViewController.refresh(_:)), forControlEvents: .ValueChanged)
        myTableView.addSubview(refreshControl)
        
        DataManager.sharedData.loadData {
            self.loadFromManager()
        }
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func switchSortingAction(sender: UISegmentedControl) {
        sortByDistance = (sender.selectedSegmentIndex == 1)
        if sortByDistance && DataManager.sharedData.currentLocation == nil {
            // pas de localisatin disponible
            sender.selectedSegmentIndex = 0
        } else {
            loadFromManager()
        }
    }
    
    //MARK: - Data
    
    func refresh(sender:AnyObject) {
        DataManager.sharedData.loadData {
            self.loadFromManager()
            self.refreshControl.endRefreshing()
        }
    }
    
    func loadFromManager() {
        items = DataManager.sharedData.datas
        if sortByDistance {
            NSOperationQueue().addOperationWithBlock({
                let loc = DataManager.sharedData.currentLocation
                for velo in DataManager.sharedData.datas {
                    velo.distance = loc?.distanceFromLocation(velo.location) ?? -1
                }
                dispatch_async(dispatch_get_main_queue(), {
                    self.items.sortInPlace({ $0.distance < $1.distance })
                    self.myTableView.reloadData()
                })
            })
        } else {
            items.sortInPlace({ $0.name < $1.name })
            myTableView.reloadData()
        }
    }

}

//MARK: - MFMessageComposeViewControllerDelegate
extension FirstViewController: MFMessageComposeViewControllerDelegate {
    func messageComposeViewController(controller: MFMessageComposeViewController, didFinishWithResult result: MessageComposeResult) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
}

//MARK: - BiclooCellDelegate
extension FirstViewController: BiclooCellDelegate {
    func didShareBicloo(velo: Bicloo) {
        let composeVC = MFMessageComposeViewController()
        composeVC.messageComposeDelegate = self
        composeVC.body = "Hello from \(velo.name)!"
        self.presentViewController(composeVC, animated: true, completion: nil)
    }
    
    func didOpenMapBicloo(velo: Bicloo) {
        
    }
    
    func didSearchBicloo(velo: Bicloo) {
//        UIView.animateWithDuration(0.4) {
//            self.topConstraint.constant = 140
//            self.view.layoutIfNeeded()
//        }
    }
}

//MARK: - UITableViewDelegate, UITableViewDataSource
extension FirstViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let bikeCell = tableView.dequeueReusableCellWithIdentifier("BiclooCellView")! as! BiclooCellView
        
        bikeCell.setBicloo(items[indexPath.row], and: self)
        
        return bikeCell
    }
}

