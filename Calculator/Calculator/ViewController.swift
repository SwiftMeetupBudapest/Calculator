//
//  ViewController.swift
//  Kalkulator
//
//  Created by Petneházi Károly on 2015.02.12..
//  Copyright (c) 2015 Petneházi Károly. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    
    @IBOutlet weak var display: UILabel!
    
    @IBOutlet weak var history: UILabel!
    
    var userTyped = false
    
    var brain = CalculatorBrain()
    
    
    @IBAction func appendDigit(sender: UIButton) {
        let digit =  sender.currentTitle!
        let doted = display.text?.rangeOfString(".")
        
        //println("digit = \(digit)")
        
        if (digit !=  "." || display.text?.rangeOfString(".") == nil ) {
            
            //printhistory(digit)
            
            if userTyped {
                display.text = display.text! + digit
            }else {
                display.text = digit
                userTyped = true
            }
        }
        
    }
    
    
    var displayValue : Double? {
        get {
            return NSNumberFormatter().numberFromString(display.text!)!.doubleValue
        }
        set {
            display.text = newValue == nil ? "" : "\(newValue!)"
            userTyped = false
        }
    }
    
    
    // Hogy tudom megtekinteni egy valtozo vagy func elofordulasait highlight vagy valami? ctrl+cmd+f ctrl+cmd+r
    // Minek nevezzuk a dollaros valtozokat amik az attributumra hivatkoznak? (numberedparams)
    // Hogy tudok behuzast alkalmazni, mint a tab, ami xcode-ban torli a kijelolest? cmd+[
    
    @IBAction func enter() {
        if(displayValue != nil){
            
            userTyped = false
            let result = brain.pushOperand(displayValue!)
            
            printhistory("ENTER")
            displayValue = result
            history.text = brain.description
            
        }
    }
    
    /*
    muveleti gomb: digitek kozott nem ervenyes csak a vegen
    */
    @IBAction func operate(sender: UIButton) {
        let operation =  sender.currentTitle!
        
        println("operation label = \(operation)")
        //printhistory(operation)
        
        if userTyped {
            enter()
        }
        if let result = brain.performOperation(operation){
            
            displayValue = result
            history.text = brain.description
            
        }else{
            displayValue = nil
            printhistory("ERR")
        }
        
    }
    
    
    
    // elválasztó vagy minusz jel vagy C vagy PI
    @IBAction func sign(sender: UIButton) {
        let signo =  sender.currentTitle!
        printhistory(signo)
        
        switch signo {
        case "ᐩ/-": if displayValue != nil {
            displayValue = displayValue! * -1
            }
        case "C":   history.text = ""
        displayValue = nil
        brain.pushSign(signo)
        userTyped = false
        case "CE", "π":
            let result = brain.pushSign(signo)
            displayValue = result?
            history.text = brain.description
        case ".":   appendDigit(sender)
            
        case "M":
            let result = brain.pushOperand(signo)
            displayValue = result?
        case "→M":
            let result = brain.pushOperand(signo)
            brain.variableValues[signo] = displayValue
            displayValue = result?
            
        default :   break
        }
    }
    
    
    
    
    func printhistory(msg: String) {
        if (history.text != nil) {
            history.text = history.text! + " " + "\(msg)"
        }else{
            history.text = "\(msg)"
        }
    }
    
    
}

 