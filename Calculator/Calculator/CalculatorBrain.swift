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
                                return (toFlatValue(operand.description), remOps)
                
            case .UnaryOperation(let symbol, let operation):
                
                let opeval = calculateHistory(remOps, symbol)
                return (" \(symbol)(\(opeval.result!))", opeval.remainingOps)
                
            case .BinaryOperation(let symbol, let operation):
            
                let opeval = calculateHistory(remOps, symbol)
                if let operand1 = opeval.result {
                    let opeval2 = calculateHistory(opeval.remainingOps, symbol)
                    if let operand2 = opeval2.result {
                        
                        let o1 = toFlatValue(operand1)
                        let o2 = toFlatValue(operand2)
                        
                        if preSymbol != nil && preSymbol != symbol {
                            return ("(\(o2) \(symbol) \(o1))", opeval2.remainingOps)
                        }else{
                            return ("\(o2) \(symbol) \(o1)", opeval2.remainingOps)
                        }
                        
                    }
                }
            case .Variable(let symbol):
                
                return (" \(symbol) ", remOps)
            }
        }
        return (nil, ops)
    }
    
    ///
    /// Round not nil double contained parameter to double or int. Remove zeros at the parameter end.
    ///
    func toFlatValue(numericHolder : String) ->String {
        let d1 = (numericHolder as NSString).doubleValue
        if d1 % 1 == 0 {
            return Int(d1).description
        }
        return d1.description
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
    
        var step = "start in ["+(", ".join(ops.map({ "(\($0.description))" })))+"]"
        debug(step)
        
        if(!ops.isEmpty){
            var remOps = ops
            let op = remOps.removeLast()
            switch op{
            case .Operand(let operand):
                debug("var \(operand)")
                return (operand, remOps)
            case .UnaryOperation(let symbol, let operation):
  
                debug("\(symbol) evaluate...")
                step = symbol
                
                let opeval = evaluate(remOps)
                if let operand = opeval.result {
                    debug("\(symbol)(\(operand)) evaluated")
                    return (operation(operand), opeval.remOps)
                }else{
                    debug("\(symbol)(?) nil")
                }
                
            case .BinaryOperation(let symbol, let operation):
               
                debug("\(symbol)(a,b) evaluate...")
                
                step = symbol
                
                let opeval = evaluate(remOps)
                
                if let operand1 = opeval.result {
                    let opeval2 = evaluate(opeval.remOps)
                    if let operand2 = opeval2.result {
                        debug("\(symbol)(\(operand1),\(operand2)) evaluated")
                        return (operation(operand1, operand2), opeval2.remOps)
                    }else{
                        debug("\(symbol)(a,?) nil")
                    }
                }else{
                    debug("\(symbol)(?,b) nil")
                }
                
            case .Variable(let symbol):
                
                debug("eval \(symbol):\(variableValues[symbol])")
                return (variableValues[symbol], remOps)
            }
        }
        debug("\(step) failed")
        return (nil, ops)
    }
    
    func evaluate() -> Double? {
        debug("-----------------")
        debug(nil)
        debug("stack evaluate()...")
        let (result, _) = evaluate(opStack)
        return result
    }
    
    /// Ertekek beillesztese es teljes kiertekeles
    func pushOperand(operand: Double) -> Double?{
        
        debug("pushOperand number")
        
        opStack.append(Op.Operand(operand))
        
        debug(nil)

        
        return evaluate()
    }
    
    
    
    ///  Valtozok beillesztese es teljes kiertekeles
    func pushOperand(symbol: String) -> Double?{
   
        debug("pushOperand \(symbol)")
        
        if let operation = knowOps[symbol]{
            opStack.append(operation)
        }
        
        debug(nil)
        
        return evaluate()
    }
    
    /// Muveletek beillesztese es teljes kiertekeles
    func performOperation(symbol: String) -> Double?{
        
        debug("performOperation \(symbol)")
        
        if symbol == "C"{
            opStack.removeAll()
            variableValues.removeAll()
        }else if symbol == "CE"{
            if !opStack.isEmpty {
                opStack.removeLast()
            }
        }else if let operation = knowOps[symbol]{
            opStack.append(operation)
        }
        
        
        debug(nil)

        return evaluate()
    }
    
    func debug( extraData: String? ){
        if extraData != nil {
            println(extraData!)
        }else{
            println("["+(", ".join(opStack.map({ "(\($0.description))" })))+"]")
            println(variableValues)
        }
    }
    
}
