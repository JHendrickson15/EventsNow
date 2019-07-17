//
//  CreatedEvent.swift
//  PersonProject
//
//  Created by Jordan Hendrickson on 7/15/19.
//  Copyright © 2019 Jordan Hendrickson. All rights reserved.
//

import Foundation
import CloudKit

struct Constants {
    static let recordKey = "Post"
    static let nameKey = "name"
    static let dateKey = "date"
    static let descriptionKey = "description"
    static let rosterKey = "roster"
    static let phoneKey = "phone"
    static let userReferenceKey = "userReference"
    
}

class Post {
    
    var name: String
    var date: String
    var description: String
    var roster: String
    var phone: String
    var ckRecordID: CKRecord.ID
    var userReference: CKRecord.Reference
    
    init(name: String, date: String, description: String,  roster: String, phone: String, ckRecordID: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString), userReference: CKRecord.Reference) {
        self.name = name
        self.date = date
        self.description = description
        self.roster = roster
        self.phone = phone
        self.ckRecordID = ckRecordID
        self.userReference = userReference
    }
    convenience init?(ckRecord: CKRecord) {
        guard let name = ckRecord[Constants.nameKey] as? String, let date = ckRecord[Constants.dateKey] as? String, let description = ckRecord[Constants.descriptionKey] as? String, let roster = ckRecord[Constants.rosterKey] as? String, let phone = ckRecord[Constants.phoneKey] as? String, let userReference = ckRecord[Constants.userReferenceKey] as? CKRecord.Reference else {return nil}
        
        self.init(name: name, date: date, description: description, roster: roster, phone: phone, ckRecordID: ckRecord.recordID, userReference: userReference)
    }
}
extension CKRecord{
    convenience init(post: Post) {
        self.init(recordType: Constants.recordKey, recordID: post.ckRecordID)
        self.setValue(post.name, forKey: Constants.nameKey)
        self.setValue(post.date, forKey: Constants.dateKey)
        self.setValue(post.description, forKey: Constants.descriptionKey)
        self.setValue(post.roster, forKey: Constants.rosterKey)
        self.setValue(post.phone, forKey: Constants.phoneKey)
        self.setValue(post.userReference, forKey: Constants.userReferenceKey)
    }
}
extension Post: Equatable {
    static func == (lhs: Post, rhs: Post) -> Bool {
       return lhs.ckRecordID == rhs.ckRecordID
    }
}
