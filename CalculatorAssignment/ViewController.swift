//
//  ViewController.swift
//  CalculatorAssignment
//
//  Created by Юрий Бондарчук on 15.08.16.
//  Copyright © 2016 Yury Bandarchuk. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    private var userIsTyping: Bool = false
    
    private func removeLeadingZeroes(value: String) -> String {
        var result : String = ""
        var wasNonZero : Bool = false
        for char in value.characters {
            if char != "0" {
                wasNonZero = true
            }
            if char == "." && result.characters.count == 0 {
                let zero : Character = "0"
                result.append(zero)
            }
            if wasNonZero {
                result.append(char)
            }
        }
        if result.characters.count == 0 {
            let zero : Character = "0"
            result.append(zero)
        }
        return result
    }
    
    private func modify(value: String) -> String {
        var result : String = ""
        let chars = value.characters
        if !chars.contains(".") {
            var canAdd : Int = 16
            for char in chars {
                if canAdd > 0 {
                    result.append(char)
                    canAdd -= 1
                }
            }
            return result
        }
        var needDot : Bool = false
        var wasDot : Bool = false
        var canAdd : Int = 15
        for char in chars {
            canAdd -= 1
            if canAdd < 0 {
                break
            }
            if char == "." {
                wasDot = true
                continue
            }
            if char != "0" && wasDot {
                needDot = true
                break
            }
        }
        canAdd = 16
        for char in chars {
            if char == "." && needDot == false {
                break
            }
            canAdd -= 1
            if canAdd < 0 {
                break
            }
            result.append(char)
        }
        return removeLeadingZeroes(result)
    }
    
    @IBOutlet private weak var displayLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!

    private var displayValue: Double {
        get {
            return Double(displayLabel.text!)!
        }
        set {
            displayLabel.text! = modify(String(format:"%.5f", newValue))
            descriptionLabel.text! = engine.getDescription()
        }
    }
    
    @IBAction private func touchDigit(sender: UIButton) {
        let digit = sender.currentTitle!
        let displayText = displayLabel.text!
        if digit == "." {
            if userIsTyping == false {
                displayLabel!.text = "0."
                userIsTyping = true
            } else {
                if displayText.containsString(".") == false {
                    displayLabel!.text = displayText + digit
                }
            }
            return
        }
        if userIsTyping {
            displayLabel.text! = displayText + digit
        } else {
            displayLabel.text! = digit
            if digit != "0" {
                userIsTyping = true
            }
        }
    }
    
    private var engine = Engine()

    @IBAction private func performOperation(sender: UIButton) {
        if userIsTyping {
            userIsTyping = false
            engine.setValue(displayValue)
        }
        if let operation = sender.currentTitle {
            engine.performOperation(operation)
        }
        
        displayValue = engine.result
    }
    
    @IBAction private func clearDisplay(sender: UIButton) {
        userIsTyping = false
        engine.reset()
        displayValue = 0.0
    }
    
}

