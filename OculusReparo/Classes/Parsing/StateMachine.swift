//
//  StateMachine.swift
//  Reparo
//
//  Created by Chris on 13/07/2016.
//  Copyright © 2016 flipbit.co.uk. All rights reserved.
//

import Foundation

/**
Reparo State Machine that parses configuration files
 */
open class StateMachine {
    fileprivate var values: [String]
    fileprivate var filename: String
    fileprivate var lineNumber: Int
    fileprivate var state: State
    fileprivate var popState: State
    fileprivate var next: String
    fileprivate var directive: Directive?
    
    fileprivate enum State {
        case key
        case value
        case semicolon
        case ifDirective
        case singleLineComment
        case multiLineComment
        case doubleQuote
        case singleQuote
        case endQuote
        case push
        case endOfSection
    }

    /**
     Creates a new state machine with the given configuration string
     
     - Parameter input:      The configuration string
     - Parameter filename:   The filename of the string being parsed
     
     - Throws:               Reparo.InvalidConfigurationLine if the configuration is invalid
     */
    public init(input: String, filename: String) {
        values = input.characters.map { String($0) }
        lineNumber = 1
        state = State.key
        popState = State.key
        next = ""
        self.filename = filename
    }
    
    /**
     Reads a single line of the configuration string.  Returns nil if the next line is either the end
     of a section, or the end of the string has been reached.
     
     - Throws:               Reparo.InvalidConfigurationLine if the configuration is invalid
     
     - Returns:              A configuration line object
     */
    open func read() throws -> (line: Line?, endOfSection: Bool, endOfDocument: Bool) {
        if (values.count == 0) {
            return (line: nil, endOfSection: false, endOfDocument: true)
        }
        
        var line: Line? = Line(filename: filename, lineNumber: lineNumber)
        
        while (values.count > 0)
        {
            next = values[0]
            values.remove(at: 0)
            
            if newline() {
                lineNumber = lineNumber + 1
                
                if (line != nil) {
                    line!.lineNumber = lineNumber
                }
            }
            
            switch state {
            case State.key:
                line = try readKey(line)
                break
            case State.value:
                line = try readValue(line)
                break
            case State.ifDirective:
                line = readIfDirective(line)
                break
            case State.singleLineComment:
                line = readSingleLineComment(line)
                break
            case State.multiLineComment:
                line = readMultiLineComment(line)
                break
            case State.singleQuote:
                line = readSingleQuote(line)
                break
            case State.doubleQuote:
                line = readDoubleQuote(line)
                break
            case State.endQuote:
                line = try readEndQuote(line)
                break
            default:
                break
            }
            
            if (state == State.push || state == State.endOfSection)
            {
                break
            }
        }

        // End of section
        if (state == State.endOfSection)
        {
            // Reset state
            state = State.key
            
            return (line: nil, endOfSection: true, endOfDocument: empty)
        }
        
        // Empty data if not a section
        if let l = line, l.key == nil && l.value == nil && !l.isASection {
            line = nil
        }
            
            // Ran out of data...
        else if state == State.key || state == State.value
        {
            throw ReparoError.invalidConfigurationLine("Invalid configuration line: \(lineNumber)")
        }
        
        
        // Reset state
        if state == State.push
        {
            state = State.key
        }
        
        return (line: line, endOfSection: false, endOfDocument: empty)
    }
    
    /**
     Returns a value indicating whether the state machine has processed all configuration
     lines.
     */
    open var empty: Bool {
        return values.count == 0
    }
    
    fileprivate func readKey(_ line: Line?) throws -> Line? {
        if next == ";" {
            state = State.push
        }
        else if next == ":" {
            line?.key = trim(line?.key)
            
            state = State.value
        }
        else if peek("@if")
        {
            state = State.ifDirective
            
            values.remove(at: 0)
            values.remove(at: 0)
            
            line?.key = trim(line?.key)
        }
        else if next == "{"
        {
            state = State.push
            
            line?.key = trim(line?.key)
            
            return Section(line: line!)
        }
        else if next == "}"
        {
            if nilOrEmpty(line?.key)
            {
                state = State.endOfSection
                
                return line
            }
            else
            {
                throw ReparoError.invalidConfigurationLine("Unexpected end of section character ('}') : \(lineNumber)")
            }
        }
        else if next == "#"
        {
            if line?.key == nil || line?.key == ""
            {
                state = State.singleLineComment
                
                return nil
            }
            else
            {
                throw ReparoError.invalidConfigurationLine("Unexpected start of comment character ('#'): \(lineNumber)")
            }
        }
        else if peek("/*")
        {
            values.remove(at: 0)
            
            popState = state
            
            state = State.multiLineComment
        }
        else if whitespaceOrNewLine() && nilOrEmpty(line?.key) {
            // ignore
        }
            
        else if newline() {
            throw ReparoError.invalidConfigurationLine("Unexpected new line in configuration key: \(lineNumber)")
        }
            
            
        else if line!.key == nil {
            line!.key = next
        }
            
        else {
            line!.key = line!.key! + next
        }
        
        return line
    }
    
    fileprivate func readValue(_ line: Line?) throws -> Line? {
        // Check end of value
        if next == ";" {
            line?.value = trim(line?.value)
            
            state = State.push
        }
            
            // Ignore leading whitespace
        else if whitespace() && nilOrEmpty(line?.value)
        {
            // ignore
        }
            
            // Test for directive
        else if peek("@if") {
            values.remove(at: 0)
            values.remove(at: 0)
            
            line?.value = trim(line?.value)
            
            state =  State.ifDirective
        }
            
            // Multiline comment
        else if peek("/*") {
            values.remove(at: 0)
            
            popState = state
            
            state = State.multiLineComment
        }
            
            // Double quote
        else if next == "\"" && nilOrEmpty(line?.value) {
            line?.quoted = true
            state = State.doubleQuote
        }
            
            // Single quote
        else if next == "'" && nilOrEmpty(line?.value) {
            line?.quoted = true
            state = State.singleQuote
        }

            // New section
        else if next == "{"
        {
            state = State.push
            
            line?.value = trim(line?.value)
            
            return Section(line: line!)
        }
            
            // Invalid newline check
        else if newline() {
            throw ReparoError.invalidConfigurationLine("Unexpected new line in configuration value: \(lineNumber)")
        }
            
            // Initialize value
        else if line!.value == nil {
            line!.value = next
        }
            
            // Append value
        else {
            line!.value = line!.value! + next
        }
        
        return line
    }
    
    fileprivate func readIfDirective(_ line: Line?) -> Line? {
        if next == ";" {
            if directive != nil {
                directive!.name = trim(directive!.name)!
                line?.directives.append(directive!.clone())
                directive = nil
            }
            
            state = State.push
        }
            
        else if next == "{" {
            if directive != nil {
                directive!.name = trim(directive!.name)!
                line?.directives.append(directive!.clone())
                directive = nil
            }
            
            state = State.push
            
            return Section(line: line!)
        }
            
        else if next == "," {
            if directive != nil {
                directive!.name = trim(directive!.name)!
                line?.directives.append(directive!.clone())
            }
            
            directive = nil
        }
            
        else if next == "!" && directive == nil {
            directive = Directive(name: "", not: true)
        }
            
        else if whitespace() && directive == nil {
            // ignore
        }
            
        else if directive == nil {
            directive = Directive(name: next, not: false)
        }
            
        else {
            directive!.name = directive!.name + next
        }
        
        return line
    }
    
    fileprivate func readSingleLineComment(_ line: Line?) -> Line? {
        if newline() {
            state = State.key
            
            return Line(filename: filename, lineNumber: lineNumber)
        }
        
        return line
    }
    
    fileprivate func readMultiLineComment(_ line: Line?) -> Line? {
        if peek("*/") {
            values.remove(at: 0)
            
            state = popState
        }
        
        return line
    }
    
    fileprivate func readDoubleQuote(_ line: Line?) -> Line? {
        if peek("\"\"") {
            values.remove(at: 0)
            
            line!.value! = line!.value! + next
        }
        else if next == "\"" {
            state = State.endQuote
        }
        else if line!.value == nil {
            line!.value = next
        }
        else {
            line!.value! = line!.value! + next
        }
        
        return line
    }
    
    fileprivate func readSingleQuote(_ line: Line?) -> Line? {
        if peek("''") {
            values.remove(at: 0)
            
            line!.value! = line!.value! + next
        }
        else if next == "'" {
            state = State.endQuote
        }
        else if line!.value == nil {
            line!.value = next
        }
        else {
            line!.value! = line!.value! + next
        }
        
        return line
    }
    
    fileprivate func readEndQuote(_ line: Line?) throws -> Line? {
        if whitespace() {
            // ignore
        }
        else if next == ";" {
            state = State.push
        }
        else if peek("@if") {
            values.remove(at: 0)
            values.remove(at: 0)
            
            state = State.ifDirective
        }
        else {
            throw ReparoError.invalidConfigurationLine("Unexpected character after quoted value: \(next) \(lineNumber)")
        }
        
        return line
    }
    
    fileprivate func peek(_ input: String) -> Bool {
        if !input.hasPrefix(next) {
            return false
        }
        
        var result = false
        
        if values.count >= input.characters.count {
            var peek = next
            for i in 0...(input.characters.count - 2) {
                peek += values[i]
            }
            
            if peek == input
            {
                result = true
            }
        }
        
        return result
    }
    
    fileprivate func whitespace() -> Bool {
        if next == " "
        {
            return true
        }
        if next == "\t"
        {
            return true
        }
        
        return false
    }
    
    fileprivate func newline() -> Bool {
        if next == "\r" {
            return true
        }
        if next == "\n" {
            return true
        }
        if next == "\r\n" {
            return true
        }
        return false
    }
    
    fileprivate func whitespaceOrNewLine() -> Bool {
        return whitespace() || newline()
    }
    
    fileprivate func nilOrEmpty(_ value: String?) -> Bool {
        return value == nil || value == ""
    }
    
    fileprivate func trim(_ input: String?) -> String? {
        return input?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
}
