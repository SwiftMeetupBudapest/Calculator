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
    
    var operandStack = Array<Double>()
    
    @IBAction func operate(sender: UIButton) {
        let operation = sender.currentTitle!
        history.text = history.text! + " " + operation
        if userIsInTheMiddleOfTypingANumber {
            enter()
        }
        
        switch operation {
        case "×": performOperation { $0 * $1 }
        case "÷": performOperation { $1 / $0 }
        case "+": performOperation { $0 + $1 }
        case "−": performOperation { $1 - $0 }
        case "√": performOperation { sqrt($0) }
        case "sin": performOperation { sin($0) }
        case "cos": performOperation { cos($0) }
        case "π": performOperation()
        default: break
        }
        userIsPerformedAnOperation = true
        enter()
    }
    
    func performOperation(operation: (Double, Double) -> Double) {
        if operandStack.count >= 2 {
            displayValue = operation(operandStack.removeLast(), operandStack.removeLast())
        }
    }
    
    func performOperation(operation: Double -> Double) {
        if operandStack.count >= 1 {
            displayValue = operation(operandStack.removeLast())
        }
    }
    
    func performOperation() {
        displayValue = M_PI
    }

    @IBAction func enter() {
        userIsInTheMiddleOfTypingANumber = false
        if userIsPerformedAnOperation {
            userIsPerformedAnOperation = false
        } else {
            history.text = history.text! + " " + display.text!
        }
        operandStack.append(displayValue)
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
    @IBAction func clear(sender: UIButton) {
        history.text = ""
        display.text = ""
        operandStack = []
    }
}

