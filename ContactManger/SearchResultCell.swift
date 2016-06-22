//
//  SearchResultCell.swift
//  GoAppMedia
//
//  Created by Omar Al tawashi on 3/27/16.
//  Copyright ©  2016 unitone itc. All rights reserved.
//

import UIKit

class SearchResultCell: UITableViewCell {
    
     @IBOutlet weak var name_Label: UILabel!
    @IBOutlet weak var avatar_Image: UIImageView!
    @IBOutlet weak var FirsNameLabel: UILabel!
    @IBOutlet weak var LastNameLabel: UILabel!
    @IBOutlet weak var PhoneNumberLabel: UILabel!
    @IBOutlet weak var emailsLabel: UILabel!
    
    @IBOutlet weak var location_cityLabel: UILabel!
    
    
  
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
  

}
