//
//  MockDelayer.swift
//  Delayer
//
//  Created by Lin David, US-205 on 11/8/16.
//  Copyright © 2016 Lin David. All rights reserved.
//

import Foundation

class MockDelayer: DelayerProtocol {
    var delayFunction = {
        (seconds: Double, closure: @escaping () -> Void) in
        closure()
    }
    
    func delay(forSeconds seconds: Double, closure: @escaping () -> Void) {
        delayFunction(seconds, closure)
    }
}

class MockDelayerManagerFactory: DelayerManagerFactoryProtocol {
    let mockDelayerManager = MockDelayerManager()
    
    func createDelayerManager(nMax: Int) -> DelayerManagerProtocol {
        return mockDelayerManager
    }
}

class MockDelayerManager: DelayerManagerProtocol {
    var isAddDelayerCalled = false
    var nResetCalled = 0
    func addDelayer(forSeconds seconds: Double, closure: @escaping () -> Void) {
        isAddDelayerCalled = true
    }
    func reset() {
        nResetCalled += 1
    }
}

class MockDelayerFactory: DelayerFactoryProtocol {
    func createDelayerObject(forSeconds seconds: Double, closure: @escaping () -> Void) -> DelayerObjectProtocol {
        return MockDelayerObject()
    }
}

class MockDelayerObject: DelayerObjectProtocol {
    var isCancelCalled = false
    
    func cancel() {
        isCancelCalled = true
    }
}
