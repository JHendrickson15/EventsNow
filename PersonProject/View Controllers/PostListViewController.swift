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
    var refreshedControl = UIRefreshControl()

    @IBOutlet weak var usernameTextField: PhoneNumberTextField!
    @IBOutlet weak var passwordTextField: PhoneNumberTextField!
    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var postTableView: UITableView!
    @IBOutlet weak var tableViewTopOutlet: NSLayoutConstraint!
    @IBOutlet weak var phoneNumberTextField: PhoneNumberTextField!
    @IBOutlet weak var imageview: UIImageView!
    @IBOutlet weak var hiddenImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        shouldAutoRotate()
        supportedInterfaceOrientations()
        updateTableView()
        phoneNumberTextField.delegate = self
        phoneNumberTextField.maxLength = 10
        phoneNumberTextField.valueType = .phoneNumber
        NotificationCenter.default.addObserver(self, selector: #selector(PostListViewController.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(PostListViewController.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        // 1 everything starts out hidden
        self.hiddenImageView.isHidden = true
        self.navigationController?.navigationBar.isHidden = true
        self.postTableView.isHidden = true
        self.tabBarController?.tabBar.isHidden = true
        self.usernameTextField.isHidden = true
        self.passwordTextField.isHidden = true
        self.phoneNumberTextField.isHidden = true
        self.imageview.isHidden = true
        self.signupButton.isHidden = true
        DispatchQueue.main.async {
            self.signupPage()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if UserController.shared.currentUser == nil {
            self.signupPage()
      }
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
    
    func shouldAutoRotate() -> Bool {
        return false
    }
    
    func supportedInterfaceOrientations() -> UIInterfaceOrientationMask{
        return .portrait
    }
    
    @IBAction func signupButtonTapped(_ sender: Any) {
        guard let username = usernameTextField.text,
            !username.isEmpty,
            let password = passwordTextField.text,
            !password.isEmpty,
            let phone = phoneNumberTextField.text,
            !phone.isEmpty
            else {return}
        
        UserController.shared.createNewUser(username: username, password: password, phone: phone) { (success) in
            if success {
                print("created a new user")
                DispatchQueue.main.async {
                    self.resignFirstResponder()
                    self.postTableView.isHidden = false
                    self.usernameTextField.isHidden = true
                    self.passwordTextField.isHidden = true
                    self.phoneNumberTextField.isHidden = true
                    self.imageview.isHidden = true
                    self.signupButton.isHidden = true
                    self.navigationController?.navigationBar.isHidden = false
                    self.tabBarController?.tabBar.isHidden = false
                    DispatchQueue.main.async {
                        self.postTableView.reloadData()
                    }
                    self.usernameTextField.text = ""
                    self.passwordTextField.text = ""
                    self.phoneNumberTextField.text = ""
                    return
                }
            }
        }
    }
    

    
    func signupPage(){
        UserController.shared.fetchCurrentUser { (success) in
            if success {
                print("fetched User")
                DispatchQueue.main.async {
                    self.usernameTextField.isHidden = true
                    self.passwordTextField.isHidden = true
                    self.phoneNumberTextField.isHidden = true
                    self.imageview.isHidden = true
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
                    self.usernameTextField.isHidden = false
                    self.passwordTextField.isHidden = false
                    self.phoneNumberTextField.isHidden = false
                    self.imageview.isHidden = false
                    self.signupButton.isHidden = false
                    self.navigationController?.navigationBar.isHidden = false
                    self.tabBarController?.tabBar.isHidden = true
                    self.postTableView.isHidden = true
                    
                }
            }
        }
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let userInfo = notification.userInfo else {return}
        guard let keyboardSize = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {return}
        let keyboardFrame = keyboardSize.cgRectValue
        if self.view.frame.origin.y == 0{
            self.view.frame.origin.y -= keyboardFrame.height - 150
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    
    //    func updateUserView(){
    //        UserController.shared.fetchCurrentUser { (success) in
    //            if success {
    //                print("fetched User")
    //                DispatchQueue.main.async {
    //                    self.usernameTextField.isHidden = true
    //                    self.passwordTextField.isHidden = true
    //                    self.phoneNumberTextField.isHidden = true
    //                    self.signupButton.isHidden = true
    //                    self.navigationController?.navigationBar.isHidden = false
    //                    self.tabBarController?.tabBar.isHidden = false
    //                    self.postTableView.isHidden = false
    //                    self.tableViewTopOutlet.constant = 1
    //                    self.postTableView.refreshControl = self.refreshedControl
    //                    self.refreshedControl.addTarget(self, action: #selector(self.refreshControlPulled), for: .valueChanged)
    //                }
    //            }else{
    //                print("no user here")
    //                DispatchQueue.main.async {
    //                    self.usernameTextField.isHidden = false
    //                    self.passwordTextField.isHidden = false
    //                    self.phoneNumberTextField.isHidden = false
    //                    self.signupButton.isHidden = false
    //                    self.navigationController?.navigationBar.isHidden = false
    //                    self.tabBarController?.tabBar.isHidden = true
    //                    self.postTableView.isHidden = true
    //
    //                }
    //            }
    //        }
    //    }
    // MARK: - Table view data source
    
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
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "postCellToDetailVC"{
            if let index = postTableView.indexPathForSelectedRow?.row {
                let destinationVC = segue.destination as? PostDetailViewController
                let locations = PostController.shared.post[index]
                destinationVC?.location = locations
            }
        }
    }
}
extension PostListViewController: UITextFieldDelegate{

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return self.phoneNumberTextField.verifyFields(shouldChangeCharactersIn: range, replacementString: string)
}
}
