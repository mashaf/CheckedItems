//
//  ItemTableViewCell.swift
//  CheckedItems
//
//  Created by Maria Soboleva on 11/16/18.
//  Copyright © 2018 Maria Soboleva. All rights reserved.
//

import UIKit

class ItemTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var spentLabel: UILabel!
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
    
    func configure(with item: CheckedItems) {
        
        nameLabel.text = item.item_name
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM.dd.yyyy"
        dateFinishLabel.text = dateFormatter.string(from: item.finish_date! as Date)
        
        spentLabel.text = String(item.spent_amount)
        restLabel.text  = String(item.rest_amount)
    }

}
