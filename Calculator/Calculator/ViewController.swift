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
    
    var userIsInTheMiddleOfTypingANumber = false
    
    var brain = CalculatorBrain()
    
    @IBAction func appendDigit(sender: UIButton) {
        let digit = sender.currentTitle!
        if userIsInTheMiddleOfTypingANumber {
            display.text = display.text! + digit
        } else {
            display.text = digit
            userIsInTheMiddleOfTypingANumber = true
        }
    }
    
    
    @IBAction func operate(sender: UIButton) {
        if userIsInTheMiddleOfTypingANumber {
            enter()
        }
        if let operation = sender.currentTitle {
        
        }
    }
    
    @IBAction func enter() {
        userIsInTheMiddleOfTypingANumber = false
        brain.pushOperand(displayValue)
        println("operandStack = \(operandStack)")
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
}

