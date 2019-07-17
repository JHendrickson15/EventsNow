//
//  Debouncer.swift
//  PersonProject
//
//  Created by Jordan Hendrickson on 7/16/19.
//  Copyright © 2019 Jordan Hendrickson. All rights reserved.
//

import Foundation

class Debouncer {
    
    init(timeInterval: TimeInterval) {
        self.timeInterval = timeInterval
    }
    
    typealias Handler = () -> Void
    
    var handler: Handler?
    
    private let timeInterval: TimeInterval
    
    private var timer: Timer?
    
    
    func renewInterval() {
        
        timer?.invalidate()
        
        timer = Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: false, block: { [weak self] timer in
            self?.handleTimer(timer)
        })
    }
    private func handleTimer(_ timer: Timer) {
        guard timer.isValid else {
            return
        }
        handler?()
    }
}
