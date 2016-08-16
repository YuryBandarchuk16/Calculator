//
//  Engine.swift
//  CalculatorAssignment
//
//  Created by Юрий Бондарчук on 16.08.16.
//  Copyright © 2016 Yury Bandarchuk. All rights reserved.
//

import Foundation

private func tg(angle : Double) -> Double {
    return sin(angle) / cos(angle)
}

private func ctg(angle : Double) -> Double {
    return 1 / ctg(angle)
}

private let PI = 3.141592
private let E = 2.718281

class Engine {
    
    private var currentResult : Double = 0.0
    private var currentDescription : String = ""
    
    internal func setValue(value : Double) {
        currentResult = value
        currentDescription = String(format: "%g", value)
    }
    
    private enum Operation {
        case Constant(Double)
        case UnaryOperation((Double) -> Double, (String) -> String)
        case BinaryOperation((Double, Double) -> Double, (String, String) -> String)
        case Equals
    }
    
    var result : Double {
        get {
            return currentResult
        }
    }
    
    private var operations: Dictionary<String,Operation> = [
        "π" : Operation.Constant(PI),
        "e" : Operation.Constant(E),
        "±" : Operation.UnaryOperation({ -$0 }, { "-(\($0))"}),
        "√" : Operation.UnaryOperation(sqrt, { "√(\($0))"}),
        "tg" : Operation.UnaryOperation(tg, { "tg(\($0))"}),
        "cgt" : Operation.UnaryOperation(ctg, { "ctg(\($0))"}),
        "cos" : Operation.UnaryOperation(cos, { "cos(\($0))"}),
        "sin" : Operation.UnaryOperation(sin, { "sin(\($0))"}),
        "×" : Operation.BinaryOperation({ $0 * $1 }, { "\($0) × \($1)"}),
        "÷" : Operation.BinaryOperation({ $0 / $1 }, { "\($0) ÷ \($1)"}),
        "+" : Operation.BinaryOperation({ $0 + $1 }, { "\($0) + \($1)"}),
        "-" : Operation.BinaryOperation({ $0 - $1 }, { "\($0) - \($1)"}),
        "=" : Operation.Equals
    ]
    
    private var wasOperation : Bool = false
    
    internal func performOperation(symbol : String) {
        if let operation = operations[symbol] {
            switch operation {
            case .Constant(let someConstant):
                currentResult = someConstant
                currentDescription = symbol
            case .BinaryOperation(let solver, let descriptor):
                makePending()
                if wasOperation && (symbol == "×" || symbol == "÷") {
                    currentDescription = "(" + currentDescription + ")"
                }
                pending = PendingOperation(binaryFunction: solver, storedValue: currentResult, descriptionFunction: descriptor, descriptionOperand: currentDescription)
                wasOperation = true
            case .UnaryOperation(let solver, let descriptor):
                currentResult = solver(currentResult)
                currentDescription = descriptor(currentDescription)
            case .Equals:
                makePending()
            }
        }
    }
    
    private func makePending() {
        if pending != nil {
            currentResult = pending!.binaryFunction(pending!.storedValue, currentResult)
            currentDescription = pending!.descriptionFunction(pending!.descriptionOperand, currentDescription)
            pending = nil
        }
    }
    
    private var pending : PendingOperation?
    
    private struct PendingOperation {
        var binaryFunction: (Double, Double) -> Double
        var storedValue: Double
        var descriptionFunction: (String, String) -> String
        var descriptionOperand: String
    }
    
    internal func reset() {
        pending = nil
        wasOperation = false
        currentResult = 0.0
        currentDescription = "0"
    }
    
    internal func getDescription() -> String {
        if currentDescription == "0" {
            return currentDescription
        }
        var resultDescription : String = ""
        if currentDescription.hasSuffix(" ") == false {
            resultDescription = currentDescription + " "
        } else {
            resultDescription = currentDescription
        }
        if isPartialResult {
            resultDescription += "..."
        } else {
            resultDescription += "="
        }
        return resultDescription
    }
    
    private var isPartialResult : Bool {
        get {
            if pending == nil {
                return false
            } else {
                return true
            }
        }
    }
    
}
