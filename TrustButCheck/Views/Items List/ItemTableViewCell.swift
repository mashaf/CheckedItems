//
//  ItemTableViewCell.swift
//  TrustButCheck
//
//  Created by Maria Soboleva on 11/16/18.
//  Copyright © 2018 Jesse Flores. All rights reserved.
//

import UIKit

class ItemTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var spendLabel: UILabel!
    @IBOutlet weak var dateFinishLabel: UILabel!
    @IBOutlet weak var restLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
