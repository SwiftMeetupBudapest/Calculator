//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Gabor L Lizik on 15/02/15.
//  Copyright (c) 2015 Gabor L Lizik. All rights reserved.
//

import Foundation

class CalculatorBrain {
    enum Op {
        case Operand(Double)
        case unartOperation(String, Double)
        
    }
    var opStack = [Op]()
}