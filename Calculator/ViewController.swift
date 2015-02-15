//
//  ViewController.swift
//  Calculator
//
//  Created by Géza Mikló on 03/02/15.
//  Copyright (c) 2015 Géza Mikló. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    // MARK: Outlets
    @IBOutlet weak var digitsLabel: UILabel!
    @IBOutlet weak var historyLabel: UILabel!
    
    // MARK: Instance variables
    var userIsInTheMiddleOfTyping: Bool = false
//    var operandStack: Array<Double> = Array<Double>()
    var brain = CalculatorBrain()

    // MARK: ViewController methods
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        clearAll()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func clearAll() {
//        operandStack.removeAll(keepCapacity: false)
        displayValue = nil
        historyLabel.text = ""
    }
    
    // MARK: Actions
    @IBAction func appendDigit(sender: UIButton) {
        let digit = sender.currentTitle!
        println("digit = \(digit)")
        
        if (userIsInTheMiddleOfTyping) {
            var digitAppendable = true
            
            if (digit == ".") && (digitsLabel.text!.rangeOfString(".") != nil) {
                digitAppendable = false
            }

            if digitAppendable {
                digitsLabel.text = digitsLabel.text! + digit
            }
        } else {
            digitsLabel.text = digit
            userIsInTheMiddleOfTyping = true
        }
    }
    
    @IBAction func enter() {
        userIsInTheMiddleOfTyping = false
        if let result = brain.pushOperand(displayValue!) {
            historyLabel.text = historyLabel.text! + " " + digitsLabel.text!
            displayValue = result
        } else {
            displayValue = 0
        }
    }

    @IBAction func operate(sender: AnyObject) {
        if userIsInTheMiddleOfTyping {
            enter()
        }
        
        if let operation = sender.currentTitle! {
            historyLabel.text = historyLabel.text! + " " + operation
            if let result = brain.performOperation(operation) {
                historyLabel.text = historyLabel.text! + " = \(result)"
                displayValue = result
            } else {
                displayValue = 0
            }
            
        }
        
    }
    
    @IBAction func invert() {
        println("\(displayValue)")
        if let num = displayValue {
            if !userIsInTheMiddleOfTyping {
                brain.performOperation("∓")
            } else {
                displayValue = -1 * num
            }
        }
    }
    
    // MARK: Computed variables
    var displayValue: Double? {
        get {
            var textValue = "0"
            if let text = digitsLabel.text {
                textValue = text
            }
            if let dValue = NSNumberFormatter().numberFromString(textValue)?.doubleValue {
                return dValue
            } else {
                return nil
            }
        }
        set {
            if newValue == nil {
                digitsLabel.text = ""
            } else {
                digitsLabel.text = "\(newValue!)"
            }
        }
    }
    
    func performOperationPi() {
        displayValue = M_PI
        enter()
    }
    
    @IBAction func backSpace() {
        if !userIsInTheMiddleOfTyping {
            return
        }
        
        if let numText = digitsLabel.text as String! {
            digitsLabel.text = dropLast(numText)
        }
    }
}

