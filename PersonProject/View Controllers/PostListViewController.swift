//
//  PostListTableViewController.swift
//  PersonProject
//
//  Created by Jordan Hendrickson on 7/15/19.
//  Copyright © 2019 Jordan Hendrickson. All rights reserved.
//

import UIKit

class PostListViewController: UIViewController {
    
    var resultsArray: [Post] = []
    var isSearching: Bool = false
    var dataSource: [Post] {
        return isSearching ? resultsArray: PostController.shared.post
    }
    
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var postTableView: UITableView!
    @IBOutlet weak var hiddenBioView: UITextView!
    @IBOutlet weak var tableViewTopOutlet: NSLayoutConstraint!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        DispatchQueue.main.async {
//            self.postTableView.reloadData()
//            self.resultsArray = PostController.shared.post
//        }
//    }
    var refreshedControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateTableView()
        NotificationCenter.default.addObserver(self, selector: #selector(PostListViewController.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(PostListViewController.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        // 1 everything starts out hidden
        self.navigationController?.navigationBar.isHidden = true
        self.postTableView.isHidden = true
        self.hiddenBioView.isHidden = true
        self.tabBarController?.tabBar.isHidden = true
        self.usernameTextField.isHidden = true
        self.passwordTextField.isHidden = true
        self.phoneNumberTextField.isHidden = true
        self.signupButton.isHidden = true
        // hide the tab bar also
        
        // 2 fetch the user if there is one
        UserController.shared.fetchCurrentUser { (success) in
            if success {
                print("fetched User")
                DispatchQueue.main.async {
                    self.hiddenBioView.isHidden = true
                    self.usernameTextField.isHidden = true
                    self.passwordTextField.isHidden = true
                    self.phoneNumberTextField.isHidden = true
                    self.signupButton.isHidden = true
                    self.navigationController?.navigationBar.isHidden = false
                    self.tabBarController?.tabBar.isHidden = false
                    self.postTableView.isHidden = false
                    self.tableViewTopOutlet.constant = 1
                    self.postTableView.refreshControl = self.refreshedControl
                    self.refreshedControl.addTarget(self, action: #selector(self.refreshControlPulled), for: .valueChanged)
                }
            }else{
                print("no user here")
                DispatchQueue.main.async {
                    self.hiddenBioView.isHidden = true
                    self.usernameTextField.isHidden = false
                    self.passwordTextField.isHidden = false
                    self.phoneNumberTextField.isHidden = false
                    self.signupButton.isHidden = false
                    self.navigationController?.navigationBar.isHidden = false
                    self.tabBarController?.tabBar.isHidden = true
                    self.postTableView.isHidden = true
                    
                }
            }
        }
//        requestFullSyncOperation { (_) in
//        }
    }
    func updateTableView(){
        postTableView.reloadData()
    }
    @objc func refreshControlPulled() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        PostController.shared.fetchPost { (posts) in
            print("reloaded posts")
            print(posts?.count)
            DispatchQueue.main.async {
                self.postTableView.reloadData()
                self.refreshedControl.endRefreshing()
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
    }
    @IBAction func signupButtonTapped(_ sender: Any) {
        guard let username = usernameTextField.text,
            !username.isEmpty,
            let password = passwordTextField.text,
            !password.isEmpty,
            let phone = phoneNumberTextField.text,
            !phone.isEmpty,
            let bio = hiddenBioView.text,
            bio.isEmpty
            else {return}

        UserController.shared.createNewUser(username: username, password: password, bio: bio, phone: phone) { (success) in
            if success {
                print("created a new user")
                DispatchQueue.main.async {
                    self.resignFirstResponder()
                    self.postTableView.isHidden = false
                    self.hiddenBioView.isHidden = true
                    self.usernameTextField.isHidden = true
                    self.passwordTextField.isHidden = true
                    self.phoneNumberTextField.isHidden = true
                    self.signupButton.isHidden = true
                    self.navigationController?.navigationBar.isHidden = false
                    self.tabBarController?.tabBar.isHidden = false
                    
                    return
                }
            }
        }
    }
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let userInfo = notification.userInfo else {return}
        guard let keyboardSize = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {return}
        let keyboardFrame = keyboardSize.cgRectValue
        if self.view.frame.origin.y == 0{
            self.view.frame.origin.y -= keyboardFrame.height - 100
        }
    }
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    // MARK: - Table view data source
    
    //
//    func requestFullSyncOperation(completion: @escaping (Bool?) -> Void) {
//        UIApplication.shared.isNetworkActivityIndicatorVisible = true
//        PostController.shared.fetchPost { (posts) in
//            print("fetched posts")
//            print("\(posts?.count)")
//            DispatchQueue.main.async {
//                self.postTableView.reloadData()
//                UIApplication.shared.isNetworkActivityIndicatorVisible = false
//            }
//        }
//    }
    func presentSearchTermAlert(){
        let searchTermAlert = UIAlertController(title: "Slow down their buddy", message: "We need all your information.", preferredStyle: .alert)
        let closeAction = UIAlertAction(title: "Got it.", style: .default) { (action) in
            searchTermAlert.dismiss(animated: true, completion: nil)
        }
        searchTermAlert.addAction(closeAction)
        self.present(searchTermAlert, animated: true)
    }
}
extension PostListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath) as? PostListTableViewCell
        
        let selectedPost = dataSource[indexPath.row]
        cell?.postResults = selectedPost
        
        print("created event")
        
        
        return cell ?? UITableViewCell()
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "postCellToDetailVC"{
            if let index = postTableView.indexPathForSelectedRow?.row {
                let destinationVC = segue.destination as? PostDetailViewController
                
                let locations = PostController.shared.post[index]
                destinationVC?.location = locations
            }
        }
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    
    
}

