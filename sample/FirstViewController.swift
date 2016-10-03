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
    func didShareBicloo(_ velo: Bicloo)
    func didOpenMapBicloo(_ velo: Bicloo)
    func didSearchBicloo(_ velo: Bicloo)
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
        refreshControl.addTarget(self, action: #selector(FirstViewController.refresh(_:)), for: .valueChanged)
        myTableView.addSubview(refreshControl)
        
        DataManager.sharedData.loadData {
            self.loadFromManager()
        }
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func switchSortingAction(_ sender: UISegmentedControl) {
        sortByDistance = (sender.selectedSegmentIndex == 1)
        if sortByDistance && DataManager.sharedData.currentLocation == nil {
            // pas de localisatin disponible
            sender.selectedSegmentIndex = 0
        } else {
            loadFromManager()
        }
    }
    
    //MARK: - Data
    
    func refresh(_ sender:AnyObject) {
        DataManager.sharedData.loadData {
            self.loadFromManager()
            self.refreshControl.endRefreshing()
        }
    }
    
    func loadFromManager() {
        items = DataManager.sharedData.datas
        if sortByDistance {
            OperationQueue().addOperation({
                let loc = DataManager.sharedData.currentLocation
                for velo in DataManager.sharedData.datas {
                    velo.distance = loc?.distance(from: velo.location) ?? -1
                }
                DispatchQueue.main.async(execute: {
                    self.items.sort(by: { $0.distance < $1.distance })
                    self.myTableView.reloadData()
                })
            })
        } else {
            items.sort(by: { $0.name < $1.name })
            myTableView.reloadData()
        }
    }

}

//MARK: - MFMessageComposeViewControllerDelegate
extension FirstViewController: MFMessageComposeViewControllerDelegate {
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true, completion: nil)
    }
}

//MARK: - BiclooCellDelegate
extension FirstViewController: BiclooCellDelegate {
    func didShareBicloo(_ velo: Bicloo) {
        let composeVC = MFMessageComposeViewController()
        composeVC.messageComposeDelegate = self
        composeVC.body = "Hello from \(velo.name)!"
        self.present(composeVC, animated: true, completion: nil)
    }
    
    func didOpenMapBicloo(_ velo: Bicloo) {
        
    }
    
    func didSearchBicloo(_ velo: Bicloo) {
//        UIView.animateWithDuration(0.4) {
//            self.topConstraint.constant = 140
//            self.view.layoutIfNeeded()
//        }
    }
}

//MARK: - UITableViewDelegate, UITableViewDataSource
extension FirstViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let bikeCell = tableView.dequeueReusableCell(withIdentifier: "BiclooCellView")! as! BiclooCellView
        
        bikeCell.setBicloo(items[(indexPath as NSIndexPath).row], and: self)
        
        return bikeCell
    }
}

