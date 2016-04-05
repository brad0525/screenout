//
//  MessageTableViewCell.swift
//  ScreenOut
//
//  Created by Hoang on 4/4/16.
//  Copyright © 2016 Eric Rohlman. All rights reserved.
//

import UIKit

class MessageTableViewCell: MGSwipeTableCell {

    @IBOutlet weak var messageLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        messageLabel.hidden = true
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
