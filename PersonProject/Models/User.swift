//
//  File.swift
//  PersonProject
//
//  Created by Jordan Hendrickson on 7/10/19.
//  Copyright © 2019 Jordan Hendrickson. All rights reserved.
//

import Foundation
import CloudKit

class User{
    
    var username: String
    var password: String
    var phone: String
    var post: [Post]?
//    var photoData: Data?
//    var photoReference: String?
    var appleUserReference: CKRecord.Reference
    var recordID: CKRecord.ID
    
    static let recordKey = "User"
    
    static let appleUserReferenceKey = "appleUserReference"
    static let phoneKey = "phone"
    static let postKey = "post"
    static let recordIdKey = "recordID"
//    static let photoReferenceKey = "photoReference"
    fileprivate static let passwordKey = "password"
    static let usernameKey = "username"
    
    init(username: String, password: String, phone: String, appleUserReference: CKRecord.Reference, recordID: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString)) {
        self.username = username
        self.password = password
        self.phone = phone
//        self.photoReference = photoReference
        self.appleUserReference = appleUserReference
        self.recordID = recordID
    }
    
    init?(ckRecord: CKRecord) {
        
        guard let username = ckRecord[User.usernameKey] as? String,
            let password = ckRecord[User.passwordKey] as? String,
            let phone = ckRecord[User.phoneKey] as? String,
//            let photoReference = ckRecord[User.photoReferenceKey] as? String,
            let appleUserReference = ckRecord[User.appleUserReferenceKey] as? CKRecord.Reference
            else {
                print("FAILED TO INITIALIZE USER")
                return nil
        }
        self.username = username
        self.password = password
        self.phone = phone
//        self.photoReference = photoReference
        self.appleUserReference = appleUserReference
        self.recordID = ckRecord.recordID
    }
}
extension CKRecord {
    convenience init(user: User) {
        self.init(recordType: User.recordKey, recordID: user.recordID)
        
        self.setValue(user.username, forKey: User.usernameKey)
        self.setValue(user.password, forKey: User.passwordKey)
        self.setValue(user.phone, forKey: User.phoneKey)
//        self.setValue(user.photoReference, forKey: User.photoReferenceKey)
        self.setValue(user.appleUserReference, forKey: User.appleUserReferenceKey)
    }
}
extension User: Equatable{
    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.recordID == rhs.recordID
    }
    
    
}
