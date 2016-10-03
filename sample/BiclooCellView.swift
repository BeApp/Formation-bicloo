//
//  BiclooCellView.swift
//  sample
//
//  Created by Cedric G on 17/05/2016.
//  Copyright © 2016 Cedric G. All rights reserved.
//

import UIKit


class BiclooCellView: UITableViewCell {
    
    weak var velo: Bicloo?
    weak var deleg: BiclooCellDelegate?
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    
    // MARK: - Life
    override func awakeFromNib() {
        
    }
    
    deinit {
        self.deleg = nil
    }
    
    // MARK: - SETTER
    func setBicloo(_ velo: Bicloo, and delegate: BiclooCellDelegate) {
        self.velo = velo
        self.deleg = delegate
        titleLabel.text = velo.name
        descLabel.text = velo.address
    }
    
    //MARK: - Action
    
    @IBAction func shareAction(_ sender: UIButton) {
        guard let bicloo = velo else {
            return
        }
        deleg?.didShareBicloo(bicloo)
    }
    
    @IBAction func mapAction(_ sender: UIButton) {
        guard let bicloo = velo else {
            return
        }
        deleg?.didOpenMapBicloo(bicloo)
    }
    
    @IBAction func searchAction(_ sender: UIButton) {
        guard let bicloo = velo else {
            return
        }
        deleg?.didSearchBicloo(bicloo)
    }
    
}
