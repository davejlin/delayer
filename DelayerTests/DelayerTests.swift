//
//  DelayerTests.swift
//  Delayer
//
//  Created by Lin David, US-205 on 11/8/16.
//  Copyright © 2016 Lin David. All rights reserved.
//

import XCTest

class DelayerTests: XCTestCase {
    let delayInterval = 0.5
    let nMax = 3
    let mockDelayer = MockDelayer()
    let mockDelayerFactory = MockDelayerFactory()
    
    override func setUp() {
        super.setUp()
        
        mockDelayer.delayFunction = delayFunction
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testDelayer() {
        let expectation = self.expectation(description: "delayer should delay")
        let delayInterval = 0.5
        let delayer = Delayer()
        
        delayer.delay(forSeconds: delayInterval) {
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 2.0*delayInterval, handler: nil)
    }
    
    func testDelayerObject() {
        let expectation = self.expectation(description: "delayer object should delay")
        
        _ = DelayerObject(delayer: mockDelayer, forSeconds: delayInterval) {
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 2.0*delayInterval, handler: nil)
    }
    
    func testDelayerObject_CancelBlock() {
        let expectation = self.expectation(description: "delayer object block should be canceled")
        
        let delayerObject = DelayerObject(delayer: mockDelayer, forSeconds: delayInterval) {
            XCTFail()
        }
        
        delayerObject.cancel()
        
        let _ = DelayerObject(delayer: mockDelayer, forSeconds: 2.0*delayInterval) {
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 3.0*delayInterval, handler: nil)
    }
    
    func testDelayerFactory() {
        let expectation = self.expectation(description: "delayer factory should create delayer object")
        
        let delayerFactory = DelayerFactory(delayer: mockDelayer)
        let delayerObject = delayerFactory.createDelayerObject(forSeconds: delayInterval) {
            expectation.fulfill()
        }
        
        XCTAssertTrue((delayerObject as Any) is DelayerObjectProtocol)
        
        waitForExpectations(timeout: 2.0*delayInterval, handler: nil)
    }
    
    func testDelayerManager_AddDelayerStopsAtMaximum() {
        let delayerManager = DelayerManager(delayerFactory: mockDelayerFactory, nMax: nMax)
        let superMax = nMax+10
        
        for _ in 0 ..< superMax {
            delayerManager.addDelayer(forSeconds: delayInterval) {}
        }
        
        XCTAssertEqual(nMax, delayerManager.delayers.count)
    }
    
    func testDelayerManager_Reset() {
        let expectation = self.expectation(description: "delayer manager reset cancels and reinits delayers")
        
        // note: we need to use real Delayer and DelayerFactory in this test to ensure reset calls cancelAll
        let realDelayer = Delayer()
        let realDelayerFactory = DelayerFactory(delayer: realDelayer)
        let delayerManager = DelayerManager(delayerFactory: realDelayerFactory, nMax: nMax)
        
        for _ in 0 ..< nMax {
            delayerManager.addDelayer(forSeconds: delayInterval) {
                XCTFail()
            }
        }
        
        XCTAssertEqual(nMax, delayerManager.delayers.count)
        
        delayerManager.reset()
        XCTAssertEqual(0, delayerManager.delayers.count)
        
        realDelayer.delay(forSeconds: 2.0*delayInterval) {
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 3.0*delayInterval, handler: nil)
    }
    
    func testDelayerManagerFactory() {
        let delayerManagerFactory = DelayerManagerFactory(delayerFactory: mockDelayerFactory)
        let delayerManager = delayerManagerFactory.createDelayerManager(nMax: nMax)
        
        XCTAssertTrue((delayerManager as Any) is DelayerManagerProtocol)
    }
    
    fileprivate func delayFunction(_ seconds: Double, closure: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            closure()
        }
    }
}

