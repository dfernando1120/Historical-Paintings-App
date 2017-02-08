//
//  PaintingTableViewCell.swift
//  Historical-Paintings
//
//  Created by Dillon Fernando on 2/7/17.
//  Copyright © 2017 Dillon Fernando. All rights reserved.
//

import UIKit

class PaintingTableViewCell: UITableViewCell {

    
    @IBOutlet weak var tableViewImage: UIImageView!
    @IBOutlet weak var tableViewName: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        tableViewImage.layer.cornerRadius = 2
        tableViewImage.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
