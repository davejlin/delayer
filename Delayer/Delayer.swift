//
//  Delayer.swift
//  Delayer
//
//  Created by Lin David, US-205 on 11/8/16.
//  Copyright © 2016 Lin David. All rights reserved.
//

import Foundation

protocol DelayerProtocol {
    func delay(forSeconds seconds: Double, closure: @escaping () -> Void)
}

class Delayer: DelayerProtocol {
    func delay(forSeconds seconds: Double, closure: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            closure()
        }
    }
}

protocol DelayerManagerFactoryProtocol {
    func createDelayerManager(nMax: Int) -> DelayerManagerProtocol
}

class DelayerManagerFactory: DelayerManagerFactoryProtocol {
    fileprivate let delayerFactory: DelayerFactoryProtocol
    
    init(delayerFactory: DelayerFactoryProtocol) {
        self.delayerFactory = delayerFactory
    }
    
    func createDelayerManager(nMax: Int) -> DelayerManagerProtocol {
        return DelayerManager(delayerFactory: delayerFactory, nMax: nMax)
    }
}

protocol DelayerManagerProtocol {
    func addDelayer(forSeconds seconds: Double, closure: @escaping () -> Void)
    func reset()
}

class DelayerManager: DelayerManagerProtocol {
    var delayers: [DelayerObjectProtocol] = []
    fileprivate let delayerFactory: DelayerFactoryProtocol
    fileprivate let MAX: Int
    
    init (delayerFactory: DelayerFactoryProtocol, nMax: Int) {
        self.delayerFactory = delayerFactory
        self.MAX = nMax
    }
    
    func addDelayer(forSeconds seconds: Double, closure: @escaping () -> Void) {
        guard shouldAddDelayer() else { return }
        delayers.append(delayerFactory.createDelayerObject(forSeconds: seconds, closure: closure))
    }
    
    func reset() {
        cancelAll()
        delayers = []
    }
    
    fileprivate func cancelAll() {
        for delayer in delayers {
            delayer.cancel()
        }
    }
    
    fileprivate func shouldAddDelayer() -> Bool {
        return delayers.count < MAX
    }
}

protocol DelayerFactoryProtocol {
    func createDelayerObject(forSeconds seconds: Double, closure: @escaping () -> Void) -> DelayerObjectProtocol
}

class DelayerFactory: DelayerFactoryProtocol {
    let delayer: DelayerProtocol
    
    init(delayer: DelayerProtocol) {
        self.delayer = delayer
    }
    
    func createDelayerObject(forSeconds seconds: Double, closure: @escaping () -> Void) -> DelayerObjectProtocol {
        return DelayerObject(delayer: delayer, forSeconds: seconds, closure: closure)
    }
}

protocol DelayerObjectProtocol {
    func cancel()
}

class DelayerObject: DelayerObjectProtocol {
    var block: DispatchWorkItem
    init(delayer: DelayerProtocol, forSeconds seconds: Double, closure: @escaping () -> Void) {
        self.block = DispatchWorkItem {
            closure()
        }
        delayer.delay(forSeconds: seconds, closure: { self.block.perform() })
    }
    
    func cancel() {
        block.cancel()
    }
}

