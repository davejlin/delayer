//
//  ViewController.swift
//  Delayer
//
//  Created by Lin David, US-205 on 11/8/16.
//  Copyright © 2016 Lin David. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    let secondsDelay = 10
    let delayer = Delayer()
    let delayerFactory: DelayerFactory
    let delayerManagerFactory: DelayerManagerFactory
    let delayerManager: DelayerManagerProtocol
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var startButton: UIButton!
    
    required init?(coder aDecoder: NSCoder) {
        delayerFactory = DelayerFactory(delayer: delayer)
        delayerManagerFactory = DelayerManagerFactory(delayerFactory: delayerFactory)
        delayerManager = delayerManagerFactory.createDelayerManager(nMax: secondsDelay)
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        textView.text = "Press Start button to begin a \(secondsDelay) second delay"
        startButton.setTitle("Start \(secondsDelay) second delay", for: UIControlState())
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func startButtonPressed(_ sender: AnyObject) {
        textView.text = "\(secondsDelay) second delay started"
        delayerManager.reset()
        
        for i in 1...secondsDelay {
            delayerManager.addDelayer(forSeconds: Double(i)) {
                [weak self] in
                guard let _self = self else { return }
                if i < _self.secondsDelay {
                    _self.textView.text = "\(_self.secondsDelay-i)"
                } else {
                    _self.textView.text = "Delayer Complete!"
                }
            }
        }
    }
    
    @IBAction func cancelButtonPressed(_ sender: AnyObject) {
        textView.text = "Press Start button to begin a 10 second delay"
        delayerManager.reset()
    }
    
}

