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
        case BinaryOperation(String, (Double,Double)->Double, ((Double?,Double?)->String?)?, Int)
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
                case .BinaryOperation(let symbol, _, _, _):
                    return "\(symbol)"
                case .Variable(let symbol, _, _):
                    return "\(symbol)"
                }
            }
        }

        var precedence: Int {
            switch self {
                case .BinaryOperation(_, _, _, let precedence):
                    return precedence;
                default:
                    return Int.max
            }
        }
        
        var type: String {
            switch self {
                case .Operand:
                    return "Operand"

                case .NullaryOperation:
                    return "NullaryOperation"

                case .UnaryOperation:
                    return "UnaryOperation"

                case .BinaryOperation:
                    return "BinaryOperation"

                case .Operand:
                    return "Operand"
                
                case .Variable:
                    return "Variable"

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
    
    // MARK: init
    init(){
        func learnOp(op: Op) {
            knowOps[op.description] = op;
        }
        learnOp(Op.BinaryOperation("×", *, isOperandmissing, 100))
        learnOp(Op.BinaryOperation("+", {$0 + $1}, isOperandmissing, 50))
        learnOp(Op.BinaryOperation("−", {$1 - $0}, isOperandmissing, 25))
        learnOp(Op.BinaryOperation("÷", {$1 / $0}, { self.isOperandmissing($1, op2: $0) ?? ($0 == 0 ? "Err: Division by zero" : nil)}, 100))
        learnOp(Op.UnaryOperation("sin", {sin($0)}, nil))
        learnOp(Op.UnaryOperation("cos", {cos($0)}, nil))
        learnOp(Op.UnaryOperation("√", {sqrt($0)}) { $0! < 0 ? "Err: Negative value for \($0!) sqrt" : nil})
        learnOp(Op.UnaryOperation("∓", {-($0)}, nil))
        learnOp(Op.NullaryOperation("π") {M_PI})
    }
    


    
    // MARK: Calculated property
    var description: String? {
        get {
            var stackResults = ""
            var remainingOps = opStack
            var finished = false
            println("----------------------")
            println("Getting description")
            while !remainingOps.isEmpty {
                let (result, remainder, _) = getDescription(remainingOps)
                remainingOps = remainder
                stackResults = (result ?? "") + (stackResults == "" ? "" : ", ") + stackResults
            }
            
            return stackResults
        }
    }

    private func getDescription(ops : [Op]) -> (result: String?, remainingOps: [Op], precedence: Int) {
        if !ops.isEmpty {
            var remOps = ops
            let op = remOps.removeLast()
            println("  -----------")
            println("\t\(op.type) \(op.description), current precedence: \(op.precedence)")
            
            switch op {
                case .Operand(let operand):
                    println("\tOperand: \(operand)")
                    return (operand.description, remOps, op.precedence)
                    
                case .UnaryOperation(let symbol, let operation, _):
                    
                    println("\tOperation: \(symbol) desc...")
                    
                    let opeval = getDescription(remOps)
                    var opStr = opeval.result!
                    if opeval.precedence < op.precedence {
                        opStr = "(\(opStr))"
                    }
                    return (" \(symbol)\(opStr)", opeval.remainingOps, opeval.precedence)
                    
                case .BinaryOperation(let symbol, let operation, _, let precedence):
                    
                    println("\t\(symbol) desc...")
                    
                    let op1Evaluation = getDescription(remOps)
                    if var operand1 = op1Evaluation.result {
                        println("1. opeval1 precedence: \(op1Evaluation.precedence) - \(symbol)(\(op.precedence)::\(precedence)) ___")

                        if op.precedence > op1Evaluation.precedence {
                            operand1 = "(\(operand1))"
                        }
                        
                        let op2Evaluation = getDescription(op1Evaluation.remainingOps)

                        println("\t\topeval2 \(op2Evaluation.result) \(precedence) \(op2Evaluation.precedence)")

                        if var operand2 = op2Evaluation.result {
                            println("\t\tOp1.rem: \(op1Evaluation.remainingOps) :: \(op1Evaluation.result), Op2.rem: \(op2Evaluation.remainingOps)  :: \(op2Evaluation.result)")
                            
                            println("\nParantheses \(precedence) ? \(op.precedence) ? \(op1Evaluation.precedence) ? \(op2Evaluation.precedence)")
                            println("2. opeval1 precedence: \(op1Evaluation.precedence) - \(symbol)(\(op.precedence)::\(precedence)) - \(op2Evaluation.precedence)")
                            
                            
                            if op.precedence > op2Evaluation.precedence {
                                operand2 = "(\(operand2))"
                            }
                            
                            return ("\(operand2) \(symbol) \(operand1)", op2Evaluation.remainingOps, op.precedence)
                        }
                    }
                    return (nil, [], precedence)
                case .Variable(let symbol, _, _):
                    println("\(symbol):\(variableValues[symbol]?)")
                    return (" \(symbol) ", remOps, op.precedence)
                case .NullaryOperation(let symbol, _):
                    return (" \(symbol) ", remOps, op.precedence)
            }
        }
        
        return (nil, ops, 0)
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
                    
                case .BinaryOperation(let symbol, let operation, let errorTest, _):
                    
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
