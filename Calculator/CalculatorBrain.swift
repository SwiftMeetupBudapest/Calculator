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
        case UnaryOperation(String, Double->Double)
        case BinaryOperation(String, (Double,Double)->Double)
        case Variable(String, String -> Double?)
        case NullaryOperation(String, () -> Double)
        
        var description: String {
            get {
                switch self {
                case .Operand(let operand):
                    return "\(operand)"
                case .NullaryOperation(let symbol, _):
                    return "\(symbol)"
                case .UnaryOperation(let symbol, _):
                    return "\(symbol)"
                case .BinaryOperation(let symbol, _):
                    return "\(symbol)"
                case .Variable(let symbol, _):
                    return "\(symbol)"
                }
            }
        }

        

    }
    
    private var opStack=Array<Op>()
    private var knowOps = Dictionary<String, Op>()
    var variableValues = Dictionary<String, Double>()
    
    
    var description: String? {
        get {
            return calculateHistory(opStack).result
        }
    }
    
    private func calculateHistory(ops : [Op]) -> (result: String?, remainingOps: [Op]) {
        if(!ops.isEmpty){
            var remOps = ops
            let op = remOps.removeLast()
            switch op {
            case .Operand(let operand):
                debug("<\(operand)>")
                return (operand.description, remOps)
                
            case .UnaryOperation(let symbol, let operation):
                
                debug("\(symbol) evaluate...")
                
                let opeval = calculateHistory(remOps)
                return (" \(symbol)(\(opeval.result!))", opeval.remainingOps)
                
            case .BinaryOperation(let symbol, let operation):
                
                debug("\(symbol) evaluate...")
                
                let opeval = calculateHistory(remOps)
                if let operand1 = opeval.result {
                    let opeval2 = calculateHistory(opeval.remainingOps)
                    if let operand2 = opeval2.result {
                        return ("(\(operand2) \(symbol) \(operand1))", opeval2.remainingOps)
                    }
                }
            case .Variable(let symbol, _):
                debug("\(symbol):\(variableValues[symbol]!)")
                return (" \(symbol) ", remOps)
            case .NullaryOperation(let symbol, _):
                return (" \(symbol) ", remOps)
            }
        }
        return (nil, ops)
    }
    
    
    
    init(){
        knowOps["×"] = Op.BinaryOperation("×") {$0 * $1}
        knowOps["+"] = Op.BinaryOperation("+") {$0 + $1}
        knowOps["−"] = Op.BinaryOperation("−") {$1 - $0}
        knowOps["÷"] = Op.BinaryOperation("÷") {$1 / $0}
        knowOps["sin"] = Op.UnaryOperation("sin") {sin($0)}
        knowOps["cos"] = Op.UnaryOperation("cos") {cos($0)}
        knowOps["√"] = Op.UnaryOperation("√") {sqrt($0)}
        knowOps["π"] = Op.NullaryOperation("π") {M_PI}
    }
    
    private func evaluate(ops: [Op]) ->  (result: Double?, remOps: [Op]) {
    
        if(!ops.isEmpty){
            var remOps = ops
            let op = remOps.removeLast()
            switch op{
            case .Operand(let operand):
                debug("<\(operand)>")
                return (operand, remOps)
            case .UnaryOperation(let symbol, let operation):
  
                debug("\(symbol) evaluate...")
                
                let opeval = evaluate(remOps)
                if let operand = opeval.result {
                    return (operation(operand), opeval.remOps)
                }
                
            case .BinaryOperation(let symbol, let operation):
                
                debug("\(symbol) evaluate...")
                
                let opeval = evaluate(remOps)
                if let operand1 = opeval.result {
                    let opeval2 = evaluate(opeval.remOps)
                    if let operand2 = opeval2.result {
                        return (operation(operand1, operand2), opeval2.remOps)
                    }
                }
            case .Variable(let symbol, let operation):
                debug("\(symbol): \(variableValues[symbol]!)")
                return (operation(symbol), remOps)
                
            case .NullaryOperation(let symbol, let operation):
                return (operation(), remOps)
            }
        }
        return (nil, ops)
    }
    
    func evaluate() -> Double? {
        debug("evaluate()...")
        let (result, _) = evaluate(opStack)
        return result
    }
    
    func pushOperand(operand: Double) -> Double?{
        
        debug("pushOperand number")
        
        opStack.append(Op.Operand(operand))
        
        debug(nil)

        
        return evaluate()
    }
    
    
    
    /*
        Valtozok letrehozasa, inicializalasa es kinyerese.
    */
    func pushOperand(symbol: String) -> Double? {
        variableValues[symbol] = 0
        opStack.append(Op.Variable(symbol) { self.variableValues[$0] })
        
        debug(nil)
        
        return evaluate()
    }
    
    func performOperation(symbol: String) -> Double?{

        if let operation = knowOps[symbol]{
            opStack.append(operation)
        }
        debug(nil)

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
        
        debug(nil)
    
        return evaluate()
    }
   
    func debug( extraData: String? ){
        if extraData != nil {
            println(extraData!)
        }else{
            println("["+(", ".join(opStack.map({ "(\($0.description))" })))+"]")
        }
    }
    
    func reset() {
        opStack.removeAll()
        variableValues.removeAll()
    }
    
}
