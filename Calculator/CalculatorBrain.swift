//
//  KalkulatorBrain.swift
//  Kalkulator
//
//  Created by Géza Mikló on 03/02/15.
//  Copyright (c) 2015 Géza Mikló. All rights reserved.
//

import Foundation

class CalculatorBrain {
 
    private enum Op{
        
        case Operand(Double)
        case UnaryOperation(String, Double->Double, (Double? -> String?)?)
        case BinaryOperation(String, (Double,Double)->Double, ((Double?,Double?)->String?)?)
        case Variable(String, String -> Double?, (String? -> String?)?)
        case NullaryOperation(String, () -> Double)
        
        var description: String {
            get {
                switch self {
                case .Operand(let operand):
                    return "\(operand)"
                case .NullaryOperation(let symbol, _):
                    return "\(symbol)"
                case .UnaryOperation(let symbol, _, _):
                    return "\(symbol)"
                case .BinaryOperation(let symbol, _, _):
                    return "\(symbol)"
                case .Variable(let symbol, _, _):
                    return "\(symbol)"
                }
            }
        }

        

    }
    
    private var opStack=Array<Op>()
    private var knowOps = Dictionary<String, Op>()
    var variableValues = Dictionary<String, Double>()
    
    var errorStack = Array<String>()

    var lastError : String {
        get {
            return errorStack.isEmpty ? "" : errorStack.last!
        }
    }
    
    
    // Calculated property
    var description: String? {
        get {
            var stackResults = ""
            var remainingOps = opStack
            var finished = false
            
            while !remainingOps.isEmpty {
                let (result, remainder) = getDescription(remainingOps)
                remainingOps = remainder
                stackResults = (result ?? "") + (stackResults == "" ? "" : ", ") + stackResults
            }

            return stackResults
        }
    }
    
    private func getDescription(ops : [Op]) -> (result: String?, remainingOps: [Op]) {
        if !ops.isEmpty {
            var remOps = ops
            let op = remOps.removeLast()
            switch op {
                case .Operand(let operand):
                    println("<\(operand)>")
                    return (operand.description, remOps)
                    
                case .UnaryOperation(let symbol, let operation, _):
                    
                    println("\(symbol) desc...")
                    
                    let opeval = getDescription(remOps)
                    return (" \(symbol)(\(opeval.result!))", opeval.remainingOps)
                    
                case .BinaryOperation(let symbol, let operation, _):
                    
                    println("\(symbol) desc...")
                    
                    let opeval = getDescription(remOps)
                    if let operand1 = opeval.result {
                        println("opeval \(opeval)")

                        let opeval2 = getDescription(opeval.remainingOps)
                        println("opeval2 \(opeval2)")

                        if let operand2 = opeval2.result {
                            println("Op1.rem: \(opeval.remainingOps) :: \(opeval.result), Op2.rem: \(opeval2.remainingOps)  :: \(opeval2.result)")
                            
                            if opeval2.remainingOps.isEmpty && opeval.remainingOps.isEmpty {
                                return ("\(operand2) \(symbol) \(operand1)", opeval2.remainingOps)
                            }
                            
                            if opeval2.remainingOps.count > 1 {
                                return ("(\(operand2)) \(symbol) \(operand1)", opeval2.remainingOps)
                            }
                            
                            return ("(\(operand2) \(symbol) \(operand1))", opeval2.remainingOps)
                        }
                    }
                    return (nil, [])
                case .Variable(let symbol, _, _):
                    println("\(symbol):\(variableValues[symbol]?)")
                    return (" \(symbol) ", remOps)
                case .NullaryOperation(let symbol, _):
                    return (" \(symbol) ", remOps)
            }
        }
        
        return (nil, ops)
    }
    
    
    
    init(){
        knowOps["×"] = Op.BinaryOperation("×", *, isOperandmissing)
        knowOps["+"] = Op.BinaryOperation("+", {$0 + $1}, isOperandmissing)
        knowOps["−"] = Op.BinaryOperation("−", {$1 - $0}, isOperandmissing)
        knowOps["÷"] = Op.BinaryOperation("÷", {$1 / $0}) { self.isOperandmissing($1, op2: $0) ?? ($0 == 0 ? "Err: Division by zero" : nil)}
        knowOps["sin"] = Op.UnaryOperation("sin", {sin($0)}, nil)
        knowOps["cos"] = Op.UnaryOperation("cos", {cos($0)}, nil)
        knowOps["√"] = Op.UnaryOperation("√", {sqrt($0)}) { $0! < 0 ? "Err: Negative value for \($0!) sqrt" : nil}
        knowOps["∓"] = Op.UnaryOperation("∓", {-($0)}, nil)
        knowOps["π"] = Op.NullaryOperation("π") {M_PI}
    }
    
    // Used with multiple operations - thus a func is better
    func isOperandmissing(op1: Double?, op2: Double?) -> String? {
        if let op1Val = op1 {
            if let op2Val = op2 {
                return nil
            }
        }
        return "Err: missing operand"
    }
    
    
    
    
    // MARK: Stack evaluation
    
    private func evaluate(ops: [Op]) ->  (result: Double?, remainingOps: [Op]) {
    
        if(!ops.isEmpty){
            var remOps = ops
            let op = remOps.removeLast()
            switch op{
            
                case .Operand(let operand):
                    println("<\(operand)>")
                    return (operand, remOps)
                
                case .UnaryOperation(let symbol, let operation, let errorTest):
      
                    println("\(symbol) evaluate...")
                    
                    let opeval = evaluate(remOps)
                    if let operand = opeval.result {
                        if let error = errorTest?(operand) {
                            errorStack.append(error)
                            println("Unary operation failed: \(errorStack)")
                            return(nil, opeval.remainingOps)
                        }
                        return (operation(operand), opeval.remainingOps)
                    }
                    
                case .BinaryOperation(let symbol, let operation, let errorTest):
                    
                    println("\(symbol) evaluate...")
                    
                    let opeval = evaluate(remOps)
                    if let operand1 = opeval.result {
                        let opeval2 = evaluate(opeval.remainingOps)
                        if let operand2 = opeval2.result {
                            if let error = errorTest?(operand1, operand2) {
                                errorStack.append(error)
                                println(errorStack)
                            }
                            return (operation(operand1, operand2), opeval2.remainingOps)
                        } else {
                            if let error = errorTest?(operand1, nil) {
                                errorStack.append(error)
                                println(errorStack)
                            }
                        }
                    } else {
                        if let error = errorTest?(nil, nil) {
                            errorStack.append(error)
                            println(errorStack)
                        }
                    }
                case .Variable(let symbol, let operation, let errorTest):
                    println("\(symbol): \(variableValues[symbol] ?? 0)")
                    if let error = errorTest?(symbol) {
                        errorStack.append(error)
                        println(errorStack)
                        return (nil, remOps)
                    }
                    return (operation(symbol), remOps)
                    
                case .NullaryOperation(let symbol, let operation):
                    return (operation(), remOps)
            }
        }
        return (nil, ops)
    }
    
    func evaluate() -> Double? {
        println("---------------------------")
        println("evaluate")
        
        // Clear the error stack
        errorStack.removeAll()
        
        let (result, _) = evaluate(opStack)
        return result
    }

    func evaluateAndReportErrors() -> String? {
        evaluate()
        return lastError
    }
    
    
    
    // MARK: Stack operations
    
    // Adds a new operand
    func pushOperand(operand: Double) -> Double?{
        println("pushOperand number \(operand)")
        opStack.append(Op.Operand(operand))
        
        return evaluate()
    }
    
    
    
    // Create a new variable - adds it to stack
    func pushOperand(symbol: String) -> Double? {
        // Default value, but see project 2 extra 3 -> should display error if variable has not been set
        //variableValues[symbol] = 0
        opStack.append(Op.Variable(
                symbol,
                { self.variableValues[$0] },
            
            
                { (symbol: String?) -> String? in
                    if let varValue = self.variableValues[symbol!] {
                        return nil
                    } else {
                        return "Err: missing variable value"
                    }
                }
            )
        )
        
        return evaluate()
    }
    
    func performOperation(symbol: String) -> Double?{

        if let operation = knowOps[symbol]{
            opStack.append(operation)
        } else {
            errorStack.append("Err: invalid operation \(symbol)")
        }

        return evaluate()
    }
    
    
    
    
    // MARK: Reset and undo
    
    func reset() {
        errorStack.removeAll()
        resetStack()
        resetVariables()
    }
    
    func resetStack() {
        println("Resetting stack")
        opStack.removeAll()
    }
    
    func resetVariables() {
        println("Resetting variables")
        variableValues.removeAll()
    }
    
    // Extra #2
    func undoLast() -> Double? {
        if !opStack.isEmpty {
            opStack.removeLast()
        }
        return evaluate()
    }
    
}
