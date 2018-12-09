//
//  StatTableViewCell.swift
//  RemindersApp
//
//  Created by Kaylin Zaroukian on 12/8/18.
//  Copyright © 2018 CIS 347. All rights reserved.
//

import UIKit

class StatTableViewCell: UITableViewCell {

    @IBOutlet weak var taskTitleLabel: UILabel!
    @IBOutlet weak var taskListNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
