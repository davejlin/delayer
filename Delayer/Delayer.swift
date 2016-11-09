//
//  Delayer.swift
//  Delayer
//
//  Created by Lin David, US-205 on 11/8/16.
//  Copyright © 2016 Lin David. All rights reserved.
//

import Foundation

protocol DelayerProtocol {
    func delay(forSeconds seconds: Double, closure: () -> Void)
}

class Delayer: DelayerProtocol {
    func delay(forSeconds seconds: Double, closure: () -> Void) {
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(seconds * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            closure()
        }
    }
}

protocol DelayerManagerFactoryProtocol {
    func createDelayerManager(nMax: Int) -> DelayerManagerProtocol
}

class DelayerManagerFactory: DelayerManagerFactoryProtocol {
    private let delayerFactory: DelayerFactoryProtocol
    
    init(delayerFactory: DelayerFactoryProtocol) {
        self.delayerFactory = delayerFactory
    }
    
    func createDelayerManager(nMax: Int) -> DelayerManagerProtocol {
        return DelayerManager(delayerFactory: delayerFactory, nMax: nMax)
    }
}

protocol DelayerManagerProtocol {
    func addDelayer(forSeconds seconds: Double, closure: () -> Void)
    func reset()
}

class DelayerManager: DelayerManagerProtocol {
    var delayers: [DelayerObjectProtocol] = []
    private let delayerFactory: DelayerFactoryProtocol
    private let MAX: Int
    
    init (delayerFactory: DelayerFactoryProtocol, nMax: Int) {
        self.delayerFactory = delayerFactory
        self.MAX = nMax
    }
    
    func addDelayer(forSeconds seconds: Double, closure: () -> Void) {
        guard shouldAddDelayer() else { return }
        delayers.append(delayerFactory.createDelayerObject(forSeconds: seconds, closure: closure))
    }
    
    func reset() {
        cancelAll()
        delayers = []
    }
    
    private func cancelAll() {
        for delayer in delayers {
            delayer.cancel()
        }
    }
    
    private func shouldAddDelayer() -> Bool {
        return delayers.count < MAX
    }
}

protocol DelayerFactoryProtocol {
    func createDelayerObject(forSeconds seconds: Double, closure: () -> Void) -> DelayerObjectProtocol
}

class DelayerFactory: DelayerFactoryProtocol {
    let delayer: DelayerProtocol
    
    init(delayer: DelayerProtocol) {
        self.delayer = delayer
    }
    
    func createDelayerObject(forSeconds seconds: Double, closure: () -> Void) -> DelayerObjectProtocol {
        return DelayerObject(delayer: delayer, forSeconds: seconds, closure: closure)
    }
}

protocol DelayerObjectProtocol {
    func cancel()
}

class DelayerObject: DelayerObjectProtocol {
    var block: dispatch_block_t?
    init(delayer: DelayerProtocol, forSeconds seconds: Double, closure: () -> Void) {
        self.block = dispatch_block_create(DISPATCH_BLOCK_INHERIT_QOS_CLASS, closure)
        if let _block = self.block {
            delayer.delay(forSeconds: seconds, closure: _block)
        }
    }
    
    func cancel() {
        guard let _block = self.block else { return }
        dispatch_block_cancel(_block)
        self.block = nil
    }
}

