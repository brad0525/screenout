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
    @IBOutlet weak var contentMessageLabel: UILabel!
    @IBOutlet weak var yellowReadView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
