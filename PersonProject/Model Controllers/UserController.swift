//
//  UserController.swift
//  PersonProject
//
//  Created by Jordan Hendrickson on 7/10/19.
//  Copyright © 2019 Jordan Hendrickson. All rights reserved.
//

import Foundation
import CloudKit

class UserController {
    
    static let shared = UserController()
    
    var currentUser: User? {
        didSet {
            print("CURRENT USER CHANGED", currentUser)
        }
    }
    
    let publicDB = CKContainer.default().publicCloudDatabase
    
    private init() {}
    
    //CRUD
    
    func createNewUser(username: String, password: String, bio: String, phone: String, completion: @escaping (Bool) -> Void) {
        
        CKContainer.default().fetchUserRecordID { (appleUserID, error) in
            if let error = error {
                print("there was an error obtaining USER data. \(error.localizedDescription)")
                completion(false)
                return
            }
            guard let appleUserID = appleUserID else {completion(false) ; return}
            
            let appleUserReference = CKRecord.Reference(recordID: appleUserID, action: .deleteSelf)
            
            let newUser = User(username: username, password: password, phone: phone, appleUserReference: appleUserReference)
            
            let userRecord = CKRecord(user: newUser)
            
            self.publicDB.save(userRecord, completionHandler: { (_, error) in
                if let error = error {
                    print("error saving USER: \(error.localizedDescription)")
                    completion(false)
                    return
                }
                self.currentUser = newUser
                completion(true)
            })
        }
    }
    
    func saveCurrentUser(user: User, username: String, completion: @escaping (Bool) -> Void) {
        //update user locally
        user.username = username
        //update user in the cloud
        let userId = user.recordID
        self.publicDB.fetch(withRecordID: userId) { (record, error) in
            if let error = error {
                print("there was an error updating contact cloud data | \(error.localizedDescription)")
                completion(false)
                return
            }
            guard let record = record else {completion(false); return}
            record[User.usernameKey] = username
            
            let operation = CKModifyRecordsOperation(recordsToSave: [record], recordIDsToDelete: nil)
            operation.savePolicy = .changedKeys
            operation.queuePriority = .high
            operation.qualityOfService = .userInitiated
            operation.modifyRecordsCompletionBlock = {(records, recordIDs, error) in
                completion(true)
            }
            self.publicDB.add(operation)
        }
    }
    
    func fetchCurrentUser(completion: @escaping (Bool) -> Void){
        CKContainer.default().fetchUserRecordID { (appleUserRecordID, error) in
            if let error = error {
                print("there was an error getting current USERS. \(error.localizedDescription)")
                completion(false)
                return
            }
            guard let appleUserRecordID = appleUserRecordID else {completion(false) ; return}
            
            let appleUserReference = CKRecord.Reference(recordID: appleUserRecordID, action: .deleteSelf)
            
            let predicate = NSPredicate(format: "%K == %@", User.appleUserReferenceKey, appleUserReference)
            
            let query = CKQuery(recordType: User.recordKey, predicate: predicate)
            
            self.publicDB.perform(query, inZoneWith: nil, completionHandler: { (records, error) in
                if let error = error {
                    print("there was an error getting USERS record ID. \(error.localizedDescription)")
                    completion(false)
                    return
                }
                guard let record = records,
                    let userRecord = record.first
                    else {completion(false) ; return}
                
                let currentUser = User(ckRecord: userRecord)
                self.currentUser = currentUser
                completion(true)
            })
        }
    }
}
