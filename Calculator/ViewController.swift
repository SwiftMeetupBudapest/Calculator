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
    var operandStack: Array<Double> = Array<Double>()

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
        operandStack.removeAll(keepCapacity: false)
        digitsLabel.text = "0"
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
        operandStack.append(displayValue)
        historyLabel.text = historyLabel.text! + " " + digitsLabel.text!
        println("operandStack = \(operandStack)")
    }

    @IBAction func operate(sender: AnyObject) {
        let operation = sender.currentTitle!
        if userIsInTheMiddleOfTyping {
            enter()
        }
        
        historyLabel.text = historyLabel.text! + " " + operation!
        
        var result: Double = 0;
        switch operation! {
            case "×":
//                performOperation(*)
//                performOperation({$0 * $1})
                performOperation { $0 * $1 }
            case "÷":
                performOperation() {
                    (op1: Double, op2: Double)  -> Double in
                    if (op2 == 0) {
                        return 0
                    } else {
                        return op2 / op1
                    }
                }
            case "+":
                performOperation {$0 + $1}
            case "−":
                performOperation {$1 - $0}
            case "√":
                performOperation {sqrt($0)}
            case "sin":
                performOperation {sqrt($0)}
            case "cos":
                performOperation {sqrt($0)}
            case "π":
                performOperationPi()
            
            default: break
            
        }
    }
    
    @IBAction func invert() {
        let num = displayValue
        println("\(displayValue)")
        displayValue = -1 * num
        if !userIsInTheMiddleOfTyping {
            operandStack[operandStack.count - 1] = displayValue
        }
    }
    
    // MARK: Computed variables
    var displayValue: Double {
        get {
            var textValue = "0"
            if let text = digitsLabel.text {
                textValue = text
            }
            return NSNumberFormatter().numberFromString(textValue)!.doubleValue
        }
        set {
            digitsLabel.text = "\(newValue)"
        }
    }
    
    func performOperation(operation: (Double, Double) -> Double) {
        if operandStack.count >= 2 {
            historyLabel.text =  "="
            displayValue = operation(operandStack.removeLast(), operandStack.removeLast())
            enter()
        }
        
    }

    func performOperation(operation: Double -> Double) {
        if operandStack.count >= 1 {
            historyLabel.text = historyLabel.text! + "="
            displayValue = operation(operandStack.removeLast())
            enter()
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

