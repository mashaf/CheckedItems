//
//  ItemTableViewCell.swift
//  CheckedItems
//
//  Created by Maria Soboleva on 11/16/18.
//  Copyright © 2018 Maria Soboleva. All rights reserved.
//

import UIKit

class ItemTableViewCell: UITableViewCell {

    @IBOutlet weak var nameTextField: UILabel!
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

        let checkedItemViewModel = CheckItemViewModel(item: item)
        
        nameTextField.text   = checkedItemViewModel.itemName
        dateFinishLabel.text = checkedItemViewModel.finishDate
        spentLabel.text      = checkedItemViewModel.spentAmount
        restLabel.text       = checkedItemViewModel.restAmount
    }

}
