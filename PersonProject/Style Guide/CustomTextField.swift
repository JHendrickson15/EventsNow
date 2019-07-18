//
//  CustomTextField.swift
//  PersonProject
//
//  Created by Jordan Hendrickson on 7/10/19.
//  Copyright © 2019 Jordan Hendrickson. All rights reserved.
//

import UIKit

class SpecialTextField: UITextField {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let flexiblespace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done
            , target: self, action: #selector(dismissKeyboard))
        toolbar.setItems([flexiblespace, doneButton], animated: false)
        self.inputAccessoryView = toolbar
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    @objc private func dismissKeyboard() {
        self.resignFirstResponder()
    }
}
