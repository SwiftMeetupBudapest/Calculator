//
//  ViewController.swift
//  Calculator
//
//  Created by Gabor L Lizik on 01/02/15.
//  Copyright (c) 2015 Gabor L Lizik. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var display: UILabel!
    @IBOutlet weak var history: UILabel!

    var userIsInTheMiddleOfTypingANumber = false
    var userIsPerformedAnOperation = false
    
    var brain = CalculatorBrain()
    
    @IBAction func appendDigit(sender: UIButton) {
        let digit = sender.currentTitle!
        if userIsInTheMiddleOfTypingANumber {
            if digit == "." && (display.text?.rangeOfString(".") != nil) {
                return // invalid input
            }
            display.text = display.text! + digit
        } else {
            if digit == "." {
                display.text = "0."
            } else {
                display.text = digit
            }
            userIsInTheMiddleOfTypingANumber = true
            if userIsPerformedAnOperation {
                history.text = ""
            }
        }
        
    }
    
    
    @IBAction func operate(sender: UIButton) {
        if userIsInTheMiddleOfTypingANumber {
            enter()
        }
        
        if let operation = sender.currentTitle {
            history.text = history.text! + " " + operation
            if let result = brain.performOperation(operation) {
                displayValue = result
            } else {
                displayValue = 0
            }
        }
    }
    
    @IBAction func enter() {
        userIsInTheMiddleOfTypingANumber = false
        if let result = brain.pushOperand(displayValue) {
            displayValue = result
        } else {
            displayValue = 0
        }
        if userIsPerformedAnOperation {
            userIsPerformedAnOperation = false
        } else {
            history.text = history.text! + " " + display.text!
        }
    }
    
    // computed properties, convert string to double
    var displayValue: Double {
        get {
            return NSNumberFormatter().numberFromString(display.text!)!.doubleValue
        }
        set {
            display.text = "\(newValue)"
            userIsInTheMiddleOfTypingANumber = false
        }
    }
    @IBAction func clear(sender: UIButton) {
        history.text = ""
        display.text = ""
    }
}

