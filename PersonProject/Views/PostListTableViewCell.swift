//
//  PostListTableViewCell.swift
//  PersonProject
//
//  Created by Jordan Hendrickson on 7/15/19.
//  Copyright © 2019 Jordan Hendrickson. All rights reserved.
//

import UIKit

//protocol CustomCellUpdater: class {
//    func updateTableView()
//}

class PostListTableViewCell: UITableViewCell {
    
//    weak var delegate: CustomCellUpdater?
//
//    func yourFunctionWhichDoesNotHaveASender () {
//        delegate?.updateTableView()
//    }
    
    var postResults: Post?{
        didSet{
            updateViews()
        }
    }
    
    @IBOutlet weak var postNameLabel: UILabel!
    @IBOutlet weak var postDateLabel: UILabel!
    @IBOutlet weak var postRosterLabel: UILabel!
    @IBOutlet weak var postDescriptionLabel: UILabel!
    @IBOutlet weak var tapToJoinLabel: UILabel!
    @IBOutlet weak var hiddenPhoneLabel: UILabel!
    
    
    func updateViews(){
        hiddenPhoneLabel.isHidden = true
        guard let tapToJoinLabel = tapToJoinLabel else {return}
        postNameLabel.text = postResults?.name
        postDateLabel.text = postResults?.date
        postRosterLabel.text = "People: \(postResults?.roster ?? "")"
        postDescriptionLabel.text = postResults?.description ?? ""
        tapToJoinLabel.text = "Tap To Join Event!"
        hiddenPhoneLabel.text = postResults?.phone
    }
    
}
