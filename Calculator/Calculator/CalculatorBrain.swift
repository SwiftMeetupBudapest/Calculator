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
        case Variable(String)
        
        var description: String {
            get {
                switch self {
                case .Operand(let operand):
                    return "\(operand)"
                case .UnaryOperation(let symbol, _):
                    return "\(symbol)"
                case .BinaryOperation(let symbol, _):
                    return "\(symbol)"
                case .Variable(let symbol):
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
            return calculateHistory(opStack, nil).result

        }
    }
    
    private func calculateHistory(ops : [Op], _ preSymbol: String?) -> (result: String?, remainingOps: [Op]) {
        if(!ops.isEmpty){
            var remOps = ops
            let op = remOps.removeLast()
            switch op{
            case .Operand(let operand):
                                return (operand.description, remOps)
                
            case .UnaryOperation(let symbol, let operation):
                
                let opeval = calculateHistory(remOps, symbol)
                return (" \(symbol)(\(opeval.result!))", opeval.remainingOps)
                
            case .BinaryOperation(let symbol, let operation):
            
                let opeval = calculateHistory(remOps, symbol)
                if let operand1 = opeval.result {
                    let opeval2 = calculateHistory(opeval.remainingOps, symbol)
                    if let operand2 = opeval2.result {
                        if preSymbol != nil && preSymbol != symbol {
                            return ("(\(operand2) \(symbol) \(operand1))", opeval2.remainingOps)
                        }else{
                            return ("\(operand2) \(symbol) \(operand1)", opeval2.remainingOps)
                        }
                        
                    }
                }
            case .Variable(let symbol):
                
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
        knowOps["π"] = Op.Variable("π")
        knowOps["M"] = Op.Variable("M")

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
            case .Variable(let symbol):
                debug("\(symbol):\(variableValues[symbol]!)")
                return (variableValues[symbol], remOps)
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
    func pushOperand(symbol: String) -> Double?{
   
        if symbol == "→M" || symbol == "π"{
            variableValues.updateValue(-0, forKey: symbol)
        }
        
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
    
    func pushSign(symbol: String?) -> Double?{
        
        var result: Double?
        
        if symbol! == "C"{
            opStack.removeAll()
        }else if symbol! == "CE"{
            if !opStack.isEmpty {
                opStack.removeLast()
//                switch opStack.removeLast() {
//                case .Operand(_):
//                    result = ops
//                }
            }
        }else if symbol! == "π"{
            
            pushOperand(symbol!)
            performOperation(symbol!)
            variableValues[symbol!] = M_PI
            println("set PI \(variableValues)")
            result = M_PI
        }
        
        debug(nil)
    
        return result
    }
   
    func debug( extraData: String? ){
        if extraData != nil {
            println(extraData!)
        }else{
            println("["+(", ".join(opStack.map({ "(\($0.description))" })))+"]")
        }
    }
    
}
