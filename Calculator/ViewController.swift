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
    let decimalSeparator = NSNumberFormatter().decimalSeparator ?? "."

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

    
    
    
    // MARK: Actions

    @IBAction func clearAll() {
        displayValue = nil
        brain.reset()
        updateHistoryLabel(false)
        userIsInTheMiddleOfTyping = false
    }
    
    @IBAction func appendDigit(sender: UIButton) {
        let digit = sender.currentTitle!
        println("digit = \(digit)")
        
        if (userIsInTheMiddleOfTyping) {
            
            if (digit == ".") && (digitsLabel.text!.rangeOfString(".") != nil) {
                return
            }
            
            digitsLabel.text = digitsLabel.text! + digit
            
        } else {
            
            digitsLabel.text = digit
            userIsInTheMiddleOfTyping = true
            
        }
        updateHistoryLabel(false)
    }
    
    @IBAction func enter() {
        if (!userIsInTheMiddleOfTyping) {
            return
        }

        userIsInTheMiddleOfTyping = false
        if let dValue = displayValue {
            if let result = brain.pushOperand(dValue) {
                updateHistoryLabel(false)
            } else {
                displayValue = 0
            }
        }
    }

    @IBAction func operate(sender: AnyObject) {
        if let operation = sender.currentTitle! {
            if userIsInTheMiddleOfTyping {
                if (operation == "∓") {
                    if let num = displayValue {
                        displayValue = -1 * num
                    }
                    historyLabel.text = brain.description
                    return
                }
                enter()
            }
            displayValue = brain.performOperation(operation)
        }
        updateHistoryLabel(true)
    }

    // Sets the variable's value in stack
    @IBAction func replaceVariable(sender: UIButton) {
        if let symbol = sender.currentTitle {
            if let dVal = displayValue {
                
                // Get the variable's name
                let modSymbol = symbol.stringByReplacingOccurrencesOfString("→", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
                
                // Set the variable's value in brain
                brain.variableValues[modSymbol] = dVal

                userIsInTheMiddleOfTyping = false
                displayValue = brain.evaluate()
                updateHistoryLabel(true)
            }
        }
    }
    
    // Adds a new variable to stack
    @IBAction func addVariable(sender: UIButton) {
        if (userIsInTheMiddleOfTyping) {
            enter()
        }
        if let symbol = sender.currentTitle {
            brain.pushOperand(symbol)
            brain.evaluate()
            updateHistoryLabel(false)
        }
    }
    
    // MARK: Computed variables
    var displayValue: Double? {
        get {
            return NSNumberFormatter().numberFromString(digitsLabel.text!.stringByReplacingOccurrencesOfString(".", withString: decimalSeparator, options: NSStringCompareOptions.LiteralSearch, range: nil))?.doubleValue
        }
        set {
            println("New value: \(newValue)")
            if newValue == nil {
                // Error reporting - Autoshrink on Storyboard
                digitsLabel.text = brain.evaluateAndReportErrors()
            } else {
                digitsLabel.text = "\(newValue!)"
            }
        }
    }
    
    // Error is displayed at digitsLabel
    func updateHistoryLabel(equalSign : Bool) {
        historyLabel.text = brain.description
        if equalSign {
            historyLabel.text = historyLabel.text! + " ="
        }
    }
        
    @IBAction func backSpace() {
        if !userIsInTheMiddleOfTyping {
            displayValue = brain.undoLast()
            updateHistoryLabel(false)
            return
        }
        
        if let numText = digitsLabel.text as String! {
            digitsLabel.text = dropLast(numText)
        }
    }
}

