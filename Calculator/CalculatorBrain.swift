//
//  KalkulatorBrain.swift
//  Kalkulator
//
//  Created by Petneházi Károly on 2015.02.17..
//  Copyright (c) 2015 Petneházi Károly. All rights reserved.
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
    var lastError = ""
    
    var description: String? {
        get {
            var stackResults = ""
            var remainingOps = opStack
            var finished = false
            do {
                let (result, remainder) = calculateHistory(remainingOps)
                finished = remainder.isEmpty
                remainingOps = remainder
                stackResults = (result ?? "") + (stackResults == "" ? "" : ", ") + stackResults
            } while !finished

            return stackResults
        }
    }
    
    private func calculateHistory(ops : [Op]) -> (result: String?, remainingOps: [Op]) {
        if(!ops.isEmpty){
            var remOps = ops
            let op = remOps.removeLast()
            switch op {
            case .Operand(let operand):
                println("<\(operand)>")
                return (operand.description, remOps)
                
            case .UnaryOperation(let symbol, let operation, _):
                
                println("\(symbol) evaluate...")
                
                let opeval = calculateHistory(remOps)
                return (" \(symbol)(\(opeval.result!))", opeval.remainingOps)
                
            case .BinaryOperation(let symbol, let operation, _):
                
                println("\(symbol) evaluate...")
                
                let opeval = calculateHistory(remOps)
                if let operand1 = opeval.result {
                    let opeval2 = calculateHistory(opeval.remainingOps)
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
            case .Variable(let symbol, _, _):
                println("\(symbol):\(variableValues[symbol]!)")
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
    
    func isOperandmissing(op1: Double?, op2: Double?) -> String? {
        if let op1Val = op1 {
            if let op2Val = op2 {
                return nil
            }
        }
        return "Err: missing operand"
    }
    
    private func evaluate(ops: [Op]) ->  (result: Double?, remOps: [Op]) {
    
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
                        lastError = error
                        println(lastError)
                    }
                    return (operation(operand), opeval.remOps)
                }
                
            case .BinaryOperation(let symbol, let operation, let errorTest):
                
                println("\(symbol) evaluate...")
                
                let opeval = evaluate(remOps)
                if let operand1 = opeval.result {
                    let opeval2 = evaluate(opeval.remOps)
                    if let operand2 = opeval2.result {
                        if let error = errorTest?(operand1, operand2) {
                            lastError = error
                            println(lastError)
                        }
                        return (operation(operand1, operand2), opeval2.remOps)
                    } else {
                        if let error = errorTest?(operand1, nil) {
                            lastError = error
                            println(lastError)
                        }
                    }
                } else {
                    if let error = errorTest?(nil, nil) {
                        lastError = error
                        println(lastError)
                    }
                }
            case .Variable(let symbol, let operation, let errorTest):
                println("\(symbol): \(variableValues[symbol] ?? 0)")
                if let error = errorTest?(symbol) {
                    lastError = error
                    println(lastError)
                }
                return (operation(symbol) ?? 0, remOps)
                
            case .NullaryOperation(let symbol, let operation):
                return (operation(), remOps)
            }
        }
        return (nil, ops)
    }
    
    func evaluate() -> Double? {
        lastError = ""
        println("evaluate()...")
        let (result, _) = evaluate(opStack)
        return result
    }
    
    func pushOperand(operand: Double) -> Double?{
        
        println("pushOperand number \(operand)")
        
        opStack.append(Op.Operand(operand))
        
        return evaluate()
    }
    
    
    
    /*
        Valtozok letrehozasa, inicializalasa es kinyerese.
    */
    func pushOperand(symbol: String) -> Double? {
//        variableValues[symbol] = 0
        opStack.append(Op.Variable(symbol, { self.variableValues[$0] }, { (symbol: String?) -> String? in if let varValue = self.variableValues[symbol!] { return nil  } else { return "Err: missing variable value" } }))
        
        return evaluate()
    }
    
    func performOperation(symbol: String) -> Double?{

        if let operation = knowOps[symbol]{
            opStack.append(operation)
        }

        return evaluate()
    }
    
    func pushSign(symbol: String?) -> Double? {
        
        if symbol! == "C"{
            reset()
        }else if symbol! == "CE"{
            if !opStack.isEmpty {
                opStack.removeLast()
            }
        }
    
        return evaluate()
    }

    
    func reset() {
        lastError = ""
        opStack.removeAll()
        variableValues.removeAll()
    }
    
    func undoLast() {
        if opStack.isEmpty {
            return
        }
        lastError = ""
        opStack.removeLast()
        evaluate()
    }
    
}
