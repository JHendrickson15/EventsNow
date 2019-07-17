//
//  PostDetailViewController.swift
//  PersonProject
//
//  Created by Jordan Hendrickson on 7/16/19.
//  Copyright © 2019 Jordan Hendrickson. All rights reserved.
//

import UIKit
import MessageUI

class PostDetailViewController: UIViewController, MFMessageComposeViewControllerDelegate {

    var post: Post? {
        didSet{
            
        }
    }
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var rosterLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var entryTextField: UITextField!
    @IBOutlet weak var sendMessageButton: UIButton!
    @IBOutlet weak var hiddenPhoneNumberLabel: UILabel!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hiddenPhoneNumberLabel.isHidden = true
        updateViews()
        // Do any additional setup after loading the view.
    }
    var location: Post?
    

    var defaultText = "I would like to join your Group"
    
    func updateViews(){
        guard let location = location else {return}
        descriptionLabel.text = location.description
        dateLabel.text = location.date
        rosterLabel.text = "\(location.roster)"
        nameLabel.text = location.name
        hiddenPhoneNumberLabel.text = location.phone
    }
    @IBAction func sendMessageButtonTapped(_ sender: UIButton) {
        guard let phone = hiddenPhoneNumberLabel.text else {return}
        sendSMSText(phone: phone)
        print("message sent")
        print("\(entryTextField.text)")
        
    }
    func sendSMSText(phone: String){
        guard let phone = hiddenPhoneNumberLabel.text else {return}
        if (MFMessageComposeViewController.canSendText()){
            let controller = MFMessageComposeViewController()
            controller.body = "\(entryTextField.text ?? "\(defaultText)") -Sent Via EventsNow"
            controller.recipients = [phone]
            controller.messageComposeDelegate = self
            self.present(controller, animated: true, completion: nil)
        }
        navigationController?.popViewController(animated: true)
    }
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
    }
}
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

