//
//  EventsCreationViewController.swift
//  PersonProject
//
//  Created by Jordan Hendrickson on 7/10/19.
//  Copyright © 2019 Jordan Hendrickson. All rights reserved.
//

import UIKit

class EventsCreationViewController: UIViewController, UITextViewDelegate {
    
    var post: Post? {
        didSet{
            loadViewIfNeeded()
            updateViews()
        }
    }
    
    @IBOutlet weak var eventDateLabel: UILabel!
    @IBOutlet weak var eventNameLabel: UILabel!
    @IBOutlet weak var eventTextView: CustomTextView!
    @IBOutlet weak var maximumPickerView: UIPickerView!
    @IBOutlet weak var createEventButton: UIButton!
    @IBOutlet weak var hiddenRosterLabel: UILabel!
    @IBOutlet weak var eventLocationLabel: UILabel!
    @IBOutlet weak var hiddenPhoneLabel: UILabel!
    
    
    var pickerData: [String] = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateViews()
        maximumPickerView.delegate = self
        maximumPickerView.dataSource = self
        eventTextView.delegate = self
        self.hiddenRosterLabel.isHidden = true
        self.hiddenPhoneLabel.isHidden = true
        
        pickerData = ["2" , "3", "4", "5", "6" , "7" ,"8"]
        
    }
    
    var location: Event?
    
    func updateViews(){
        print(location?.name)
        guard let location = location else {print("no location");  return}
        eventDateLabel.text = location.dates.start.localDate
        eventNameLabel.text = location.name
        eventTextView.textColor = UIColor.lightGray
        eventTextView.text = ""
        eventLocationLabel.text = location._embedded.venues.first?.name
        hiddenPhoneLabel.text = UserController.shared.currentUser?.phone
        eventTextView.delegate = self
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = ""
            textView.textColor = UIColor.lightGray
        }
    }
    @IBAction func createEventButtonTapped(_ sender: Any) {
        guard let name = eventNameLabel.text, let date = eventDateLabel.text, let description = eventTextView.text, !description.isEmpty, let roster = hiddenRosterLabel.text, let phone = hiddenPhoneLabel.text, !phone.isEmpty  else {return}
        PostController.shared.createPost(name: name, date: date, description: description, roster: roster, phone: phone ) { (_) in
            DispatchQueue.main.async {
                let destinationVC = self.navigationController?.viewControllers.first as? EventsListViewController
                destinationVC?.doneCreating = true
                self.navigationController?.popViewController(animated: true)
                print("created event")
            }
        }
        }
    }
extension EventsCreationViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        hiddenRosterLabel.text = pickerData[row]
    }
    
}
