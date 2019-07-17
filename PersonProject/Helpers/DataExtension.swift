//
//  DataExtension.swift
//  JungleSales1
//
//  Created by Jared Warren on 5/6/19.
//  Copyright © 2019 Arkin Hill. All rights reserved.
//

import Foundation

extension Data {
    
     /**
     Convenient way of seeing objects within our app as JSON without having to send them anywhere.
     ```
     // Sample implementation
     // Use JSONEncoder to turn object into Data
     // Use printableJSONString as String to turn it into a String
     
     if let objectAsJSON = try? JSONEncoder().encode(object),
        let printableJSON = objectAsJSON.printableJSONString as String? {
     
            print(printableJSON)
     }
     ```
     */
    var printableJSONString: NSString? {
        guard let object = try? JSONSerialization.jsonObject(with: self, options: []),
            let data = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted]),
            let prettyPrintedString = NSString(data: data, encoding: String.Encoding.utf8.rawValue) else { return nil }
        return prettyPrintedString
    }
}
