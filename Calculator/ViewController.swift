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
    

    @IBAction func clearAll() {
//        operandStack.removeAll(keepCapacity: false)
        displayValue = nil
        brain.reset()
        historyLabel.text = brain.description
        userIsInTheMiddleOfTyping = false
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
        if (!userIsInTheMiddleOfTyping) {
            return
        }

        userIsInTheMiddleOfTyping = false
        if let dValue = displayValue {
            if let result = brain.pushOperand(dValue) {
                historyLabel.text = brain.description
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
                    return
                }
                enter()
            }
            if let result = brain.performOperation(operation) {
                historyLabel.text = brain.description
                displayValue = result
            } else {
                displayValue = 0
            }
            
        }
        
    }

    func setVariable(symbol: String, value: Double) {
        brain.variableValues[symbol] = value
    }

    
    @IBAction func addVariable(sender: UIButton) {
        if let symbol = sender.currentTitle {
            setVariable(symbol, value: M_PI)
            brain.pushOperand(symbol)
            historyLabel.text = brain.description
        }
    }
    
    // MARK: Computed variables
    var displayValue: Double? {
        get {
            var textValue = "0"
            if let text = digitsLabel.text {
                // Replacing locale dependent decimal separator
                textValue = text.stringByReplacingOccurrencesOfString(".", withString: decimalSeparator, options: NSStringCompareOptions.LiteralSearch, range: nil)
            }
            println(textValue)
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
        
    @IBAction func backSpace() {
        if !userIsInTheMiddleOfTyping {
            return
        }
        
        if let numText = digitsLabel.text as String! {
            digitsLabel.text = dropLast(numText)
        }
    }
}

