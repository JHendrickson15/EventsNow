//
//  PostController.swift
//  PersonProject
//
//  Created by Jordan Hendrickson on 7/15/19.
//  Copyright © 2019 Jordan Hendrickson. All rights reserved.
//

import Foundation
import CloudKit

class PostController {
    
    static let shared = PostController()
    
    var post: [Post] = []
    var userPosts: [Post] = []
    
    let publicDB = CKContainer.default().publicCloudDatabase
    
    
    func createPost(name: String, date: String, description: String, roster: String, phone: String, completion: @escaping (Post?) -> Void) {
        guard let userID = UserController.shared.currentUser?.recordID else { return }
        let userReference = CKRecord.Reference(recordID: userID, action: .none)
        
        let post = Post(name: name, date: date, description: description, roster: roster, phone: phone, userReference: userReference)
        self.post.append(post)
        self.userPosts.append(post)
        let postRecord = CKRecord(post: post)
        publicDB.save(postRecord) { (record, error) in
            if let error = error {
                print("there was an error | \(error.localizedDescription)")
                return
            }
            guard let record = record, let post = Post(ckRecord: record) else {completion(nil); return}
            completion(post)
        }
    }
    func deletePost(post: Post, completion: @escaping (Bool) -> ()) {
        guard let user = UserController.shared.currentUser else {return}
        let userReference = CKRecord.Reference(recordID: user.recordID, action: .none)
        guard let index = userPosts.firstIndex(of: post),
            userReference == post.userReference
            else {return}
        PostController.shared.userPosts.remove(at: index)
        publicDB.delete(withRecordID: post.ckRecordID) { (_, error) in
            if let error = error {
                print("you got some errors while trying to delete a post | \(error.localizedDescription)")
                completion(false)
                return
            }else{
            print("Post Deleted")
            completion(true)
            }
        }
    }
    func fetchPost(completion: @escaping ([Post]?) -> ()) {
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: Constants.recordKey, predicate: predicate)
        
        publicDB.perform(query, inZoneWith: nil) { (records, error) in
            if let error = error {
                print("you got some errors buddy | \(error.localizedDescription)")
                completion(nil)
                return
            }
            guard let records = records else {completion(nil); return}
            var post = records.compactMap({Post(ckRecord: $0)})
            post.sort{ $0.date < $1.date }
            self.post = post
            completion(post)
        }
    }
    
    func fetchUserPost(completion: @escaping (Bool) -> ()) {
        guard let user = UserController.shared.currentUser else {completion(false); return}
        let userReference = CKRecord.Reference(recordID: user.recordID , action: .none)
        
        let predicate = NSPredicate(format: "userReference == %@", userReference)
        let query = CKQuery(recordType: Constants.recordKey, predicate: predicate)
        
        publicDB.perform(query, inZoneWith: nil) { (records, error) in
            if let error = error {
                print("you got some errors buddy | \(error.localizedDescription)")
                completion(false)
                return
            }
            guard let records = records else {completion(false); return}
            var posts = records.compactMap({Post(ckRecord: $0)})
            posts.sort{ $0.date < $1.date }
            self.userPosts = posts
            completion(true)
        }
    }
    func subscribeToNotifications(completion: @escaping(Error?) -> Void) {
        let predicate = NSPredicate(value: true)
        
        let subscription = CKQuerySubscription(recordType: Constants.recordKey, predicate: predicate, options: .firesOnRecordCreation)
        
        let notificationInfo = CKSubscription.NotificationInfo()
        
        notificationInfo.alertBody = "New Event was created! Go check it out!"
        notificationInfo.shouldBadge = true
        notificationInfo.soundName = "default"
        
        subscription.notificationInfo = notificationInfo
        
        publicDB.save(subscription) { (_, error) in
            if let error = error {
                print("subscription did not save | \(error.localizedDescription)")
                completion(error)
                return
            }
            completion(nil)
        }
    }
    func requestDiscoverabilityAuth(completion: @escaping (CKContainer_Application_PermissionStatus, Error?) -> Void) {
        
        CKContainer.default().status(forApplicationPermission: .userDiscoverability) { (status, error) in
            guard status != .granted else { completion(.granted, error); return}
            
            CKContainer.default().requestApplicationPermission(.userDiscoverability, completionHandler: completion)
        }
    }
    func fetchAllDiscoverableUsers(completion: @escaping ([CKUserIdentity], Error?) -> Void){
        
        let discoverIdentities = CKDiscoverAllUserIdentitiesOperation()
        
        var discoveredIds: [CKUserIdentity] = []
        
        discoverIdentities.userIdentityDiscoveredBlock = { identity in
            discoveredIds.append(identity)
        }
        discoverIdentities.discoverAllUserIdentitiesCompletionBlock = { error in
            completion(discoveredIds, error)
        }
        CKContainer.default().add(discoverIdentities)
    }
    func fetchUserIdentityWith(phone: String, completion: @escaping (CKUserIdentity?, Error?) -> Void) {
        CKContainer.default().discoverUserIdentity(withPhoneNumber: phone, completionHandler: completion)
    }
}
