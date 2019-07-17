//
//  EventsListTableViewCell.swift
//  PersonProject
//
//  Created by Jordan Hendrickson on 7/10/19.
//  Copyright © 2019 Jordan Hendrickson. All rights reserved.
//

import UIKit

class EventsListTableViewCell: UITableViewCell {

    var EventsResults: Event?{
        didSet{
            updateViews()
        }
    }
    @IBOutlet weak var eventName: UILabel!
    @IBOutlet weak var eventDate: UILabel!
    @IBOutlet weak var helpLabel: UILabel!
    
   func updateViews(){
    guard let EventsResults = EventsResults else {return}
    self.eventName.text = EventsResults.name
    self.eventDate.text = EventsResults.dates.start.localDate
    self.helpLabel.text = "Tap To Create Event"
    }
}
