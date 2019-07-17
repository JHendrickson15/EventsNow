//
//  ProfileTableViewCell.swift
//  PersonProject
//
//  Created by Jordan Hendrickson on 7/15/19.
//  Copyright © 2019 Jordan Hendrickson. All rights reserved.
//

import UIKit

class ProfileTableViewCell: UITableViewCell {

    var profileResults: Post?{
        didSet{
            updateViews()
        }
    }
    
    @IBOutlet weak var postNameLabel: UILabel!
    @IBOutlet weak var postDateLabel: UILabel!
    @IBOutlet weak var postRosterLabel: UILabel!
    @IBOutlet weak var postDescriptionLabel: UILabel!
    @IBOutlet weak var hiddenPhoneNumberLabel: UILabel!
    
    
    
    func updateViews(){
        hiddenPhoneNumberLabel.isHidden = true
        postNameLabel.text = profileResults?.name
        postDateLabel.text = profileResults?.date
        postRosterLabel.text = "People: \(profileResults?.roster ?? "")"
        postDescriptionLabel.text = profileResults?.description
    }

}
