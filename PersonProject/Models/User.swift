//
//  File.swift
//  PersonProject
//
//  Created by Jordan Hendrickson on 7/10/19.
//  Copyright © 2019 Jordan Hendrickson. All rights reserved.
//

import UIKit
import CloudKit

class User{
    
    var username: String
    var password: String
    var phone: String
    var post: [Post]?
//    var photoData: Data?
//    var photo: UIImage? {
//        get {
//            guard let photoData = photoData else {return nil}
//            return UIImage(data: photoData)
//        } set {
//            photoData = newValue?.jpegData(compressionQuality: 0.5)
//        }
//    }
    var appleUserReference: CKRecord.Reference
    var recordID: CKRecord.ID
    
    static let recordKey = "User"
    
    static let appleUserReferenceKey = "appleUserReference"
    static let phoneKey = "phone"
    static let postKey = "post"
    static let recordIdKey = "recordID"
//    static let imageAssetKey = "imageAsset"
    fileprivate static let passwordKey = "password"
    static let usernameKey = "username"
    
    init(username: String, password: String, phone: String, appleUserReference: CKRecord.Reference, recordID: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString)) {
        self.username = username
        self.password = password
        self.phone = phone
        self.appleUserReference = appleUserReference
        self.recordID = recordID
//        self.photo = photo
    }
    
    convenience init?(ckRecord: CKRecord) {
        
        guard let username = ckRecord[User.usernameKey] as? String,
            let password = ckRecord[User.passwordKey] as? String,
            let phone = ckRecord[User.phoneKey] as? String,
//            let imageAsset = ckRecord[User.imageAssetKey] as? CKAsset,
            let appleUserReference = ckRecord[User.appleUserReferenceKey] as? CKRecord.Reference
            else {
                print("FAILED TO INITIALIZE USER")
                return nil
        }
//        let photoData = try? Data(contentsOf: imageAsset.fileURL)
        
        self.init(username: username, password: password, phone: phone, appleUserReference: appleUserReference, recordID: ckRecord.recordID)
    }
}
extension CKRecord {
    convenience init(user: User) {
        self.init(recordType: User.recordKey, recordID: user.recordID)
//        let temporaryDirectory = NSTemporaryDirectory()
//        let temporaryDirectoryURL = URL(fileURLWithPath: temporaryDirectory)
//        let fileURL = temporaryDirectoryURL.appendingPathComponent(UUID().uuidString).appendingPathExtension("jpg")
//
//        do {
//            try user.photoData?.write(to: fileURL)
//        }catch{
//            print("error saving image data url | \(error.localizedDescription)")
//        }
//        let imageAsset = CKAsset(fileURL: fileURL)
        
        self.setValue(user.username, forKey: User.usernameKey)
        self.setValue(user.password, forKey: User.passwordKey)
        self.setValue(user.phone, forKey: User.phoneKey)
        self.setValue(user.appleUserReference, forKey: User.appleUserReferenceKey)
//        self.setValue(imageAsset, forKey: User.imageAssetKey)
    }
}
extension User: Equatable{
    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.recordID == rhs.recordID
    }
    
    
}
