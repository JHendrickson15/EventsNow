//
//  ProfileViewController.swift
//  PersonProject
//
//  Created by Jordan Hendrickson on 7/15/19.
//  Copyright © 2019 Jordan Hendrickson. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {
    
//    var resultsArray: [Post] = []
//    var isSearching: Bool = false
//    var dataSource: [Post]
//    {
//        return isSearching ? resultsArray: PostController.shared.post
//    }
    
    @IBOutlet weak var profileImageview: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    
    @IBOutlet weak var phoneNumLabel: UILabel!
    @IBOutlet weak var postedTableView: UITableView!
    @IBOutlet weak var saveBioButton: UIButton!
    
    var imagePicker: ImagePicker!
    var user: User? = {
        return UserController.shared.currentUser
    }()
    var editMode: Bool = false
    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        DispatchQueue.main.async {
//            self.postedTableView.reloadData()
//            self.resultsArray = PostController.shared.post
//        }
//    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.saveBioButton.isHidden = true
        NotificationCenter.default.addObserver(self, selector: #selector(ProfileViewController.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ProfileViewController.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        self.postedTableView.delegate = self
        self.postedTableView.dataSource = self
        
        usernameLabel.text = UserController.shared.currentUser?.username
        phoneNumLabel.text = UserController.shared.currentUser?.phone
        profileImageview.layer.cornerRadius = profileImageview.frame.height / 2
        profileImageview.clipsToBounds = true
        profileImageview.layer.borderColor = UIColor.black.cgColor
        profileImageview.layer.borderWidth = 2
        
        PostController.shared.fetchUserPost { (success) in
            if success {
                DispatchQueue.main.async {
                    self.postedTableView.reloadData()
                }
            }
        }
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let userInfo = notification.userInfo else {return}
        guard let keyboardSize = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {return}
        let keyboardFrame = keyboardSize.cgRectValue
        if self.view.frame.origin.y == 0{
            self.view.frame.origin.y -= keyboardFrame.height
        }
    }
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        let numberOfChars = newText.count
        return numberOfChars < 70;
    }
    
    @IBAction func editBioButtonTapped(_ sender: Any) {
        saveBioButton.isHidden = false
        
    }
    @IBAction func saveBioButtonTapped(_ sender: Any) {
        saveBioButton.isHidden = true
        guard let user = UserController.shared.currentUser, let username = UserController.shared.currentUser?.username
            else {return}
        
        UserController.shared.saveCurrentUser(user: user, username: username ) { (success) in
            if success {
                print("big yeet")     }
        }
    }
} //END OF CLASS
extension ProfileViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return PostController.shared.userPosts.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "profileCell", for: indexPath) as? ProfileTableViewCell
        
        let userPosts = PostController.shared.userPosts[indexPath.row]
        cell?.profileResults = userPosts
        
        print("got your events")
        
        return cell ?? UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let post = PostController.shared.userPosts[indexPath.row]
            PostController.shared.deletePost(post: post) { (success) in
                if success {
                    DispatchQueue.main.async {
                        tableView.deleteRows(at: [indexPath], with: .fade)
                        self.postedTableView.reloadData()
                    }
                }
            }
        }
    }
    
    
}
extension ProfileViewController: UIImagePickerControllerDelegate {
    
}
