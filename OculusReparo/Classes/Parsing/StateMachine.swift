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
public class StateMachine {
    private var values: [String]
    private var filename: String
    private var lineNumber: Int
    private var state: State
    private var popState: State
    private var next: String
    private var directive: Directive?
    
    private enum State {
        case Key
        case Value
        case Semicolon
        case IfDirective
        case SingleLineComment
        case MultiLineComment
        case DoubleQuote
        case SingleQuote
        case EndQuote
        case Push
        case EndOfSection
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
        state = State.Key
        popState = State.Key
        next = ""
        self.filename = filename
    }
    
    /**
     Reads a single line of the configuration string.  Returns nil if the next line is either the end
     of a section, or the end of the string has been reached.
     
     - Throws:               Reparo.InvalidConfigurationLine if the configuration is invalid
     
     - Returns:              A configuration line object
     */
    public func read() throws -> (line: Line?, endOfSection: Bool, endOfDocument: Bool) {
        if (values.count == 0) {
            return (line: nil, endOfSection: false, endOfDocument: true)
        }
        
        var line: Line? = Line(filename: filename, lineNumber: lineNumber)
        
        while (values.count > 0)
        {
            next = values[0]
            values.removeAtIndex(0)
            
            if newline() {
                lineNumber = lineNumber + 1
                
                if (line != nil) {
                    line!.lineNumber = lineNumber
                }
            }
            
            switch state {
            case State.Key:
                line = try readKey(line)
                break
            case State.Value:
                line = try readValue(line)
                break
            case State.IfDirective:
                line = readIfDirective(line)
                break
            case State.SingleLineComment:
                line = readSingleLineComment(line)
                break
            case State.MultiLineComment:
                line = readMultiLineComment(line)
                break
            case State.SingleQuote:
                line = readSingleQuote(line)
                break
            case State.DoubleQuote:
                line = readDoubleQuote(line)
                break
            case State.EndQuote:
                line = try readEndQuote(line)
                break
            default:
                break
            }
            
            if (state == State.Push || state == State.EndOfSection)
            {
                break
            }
        }

        // End of section
        if (state == State.EndOfSection)
        {
            // Reset state
            state = State.Key
            
            return (line: nil, endOfSection: true, endOfDocument: empty)
        }
        
        // Empty data if not a section
        if let l = line where l.key == nil && l.value == nil && !l.isASection {
            line = nil
        }
            
            // Ran out of data...
        else if state == State.Key || state == State.Value
        {
            throw ReparoError.InvalidConfigurationLine("Invalid configuration line: \(lineNumber)")
        }
        
        
        // Reset state
        if state == State.Push
        {
            state = State.Key
        }
        
        return (line: line, endOfSection: false, endOfDocument: empty)
    }
    
    /**
     Returns a value indicating whether the state machine has processed all configuration
     lines.
     */
    public var empty: Bool {
        return values.count == 0
    }
    
    private func readKey(line: Line?) throws -> Line? {
        if next == ";" {
            state = State.Push
        }
        else if next == ":" {
            line?.key = trim(line?.key)
            
            state = State.Value
        }
        else if peek("@if")
        {
            state = State.IfDirective
            
            values.removeAtIndex(0)
            values.removeAtIndex(0)
            
            line?.key = trim(line?.key)
        }
        else if next == "{"
        {
            state = State.Push
            
            line?.key = trim(line?.key)
            
            return Section(line: line!)
        }
        else if next == "}"
        {
            if nilOrEmpty(line?.key)
            {
                state = State.EndOfSection
                
                return line
            }
            else
            {
                throw ReparoError.InvalidConfigurationLine("Unexpected end of section character ('}') : \(lineNumber)")
            }
        }
        else if next == "#"
        {
            if line?.key == nil || line?.key == ""
            {
                state = State.SingleLineComment
                
                return nil
            }
            else
            {
                throw ReparoError.InvalidConfigurationLine("Unexpected start of comment character ('#'): \(lineNumber)")
            }
        }
        else if peek("/*")
        {
            values.removeAtIndex(0)
            
            popState = state
            
            state = State.MultiLineComment
        }
        else if whitespaceOrNewLine() && nilOrEmpty(line?.key) {
            // ignore
        }
            
        else if newline() {
            throw ReparoError.InvalidConfigurationLine("Unexpected new line in configuration key: \(lineNumber)")
        }
            
            
        else if line!.key == nil {
            line!.key = next
        }
            
        else {
            line!.key = line!.key! + next
        }
        
        return line
    }
    
    private func readValue(line: Line?) throws -> Line? {
        // Check end of value
        if next == ";" {
            line?.value = trim(line?.value)
            
            state = State.Push
        }
            
            // Ignore leading whitespace
        else if whitespace() && nilOrEmpty(line?.value)
        {
            // ignore
        }
            
            // Test for directive
        else if peek("@if") {
            values.removeAtIndex(0)
            values.removeAtIndex(0)
            
            line?.value = trim(line?.value)
            
            state =  State.IfDirective
        }
            
            // Multiline comment
        else if peek("/*") {
            values.removeAtIndex(0)
            
            popState = state
            
            state = State.MultiLineComment
        }
            
            // Double quote
        else if next == "\"" && nilOrEmpty(line?.value) {
            line?.quoted = true
            state = State.DoubleQuote
        }
            
            // Single quote
        else if next == "'" && nilOrEmpty(line?.value) {
            line?.quoted = true
            state = State.SingleQuote
        }

            // New section
        else if next == "{"
        {
            state = State.Push
            
            line?.value = trim(line?.value)
            
            return Section(line: line!)
        }
            
            // Invalid newline check
        else if newline() {
            throw ReparoError.InvalidConfigurationLine("Unexpected new line in configuration value: \(lineNumber)")
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
    
    private func readIfDirective(line: Line?) -> Line? {
        if next == ";" {
            if directive != nil {
                directive!.name = trim(directive!.name)!
                line?.directives.append(directive!.clone())
                directive = nil
            }
            
            state = State.Push
        }
            
        else if next == "{" {
            if directive != nil {
                directive!.name = trim(directive!.name)!
                line?.directives.append(directive!.clone())
                directive = nil
            }
            
            state = State.Push
            
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
    
    private func readSingleLineComment(line: Line?) -> Line? {
        if newline() {
            state = State.Key
            
            return Line(filename: filename, lineNumber: lineNumber)
        }
        
        return line
    }
    
    private func readMultiLineComment(line: Line?) -> Line? {
        if peek("*/") {
            values.removeAtIndex(0)
            
            state = popState
        }
        
        return line
    }
    
    private func readDoubleQuote(line: Line?) -> Line? {
        if peek("\"\"") {
            values.removeAtIndex(0)
            
            line!.value! = line!.value! + next
        }
        else if next == "\"" {
            state = State.EndQuote
        }
        else if line!.value == nil {
            line!.value = next
        }
        else {
            line!.value! = line!.value! + next
        }
        
        return line
    }
    
    private func readSingleQuote(line: Line?) -> Line? {
        if peek("''") {
            values.removeAtIndex(0)
            
            line!.value! = line!.value! + next
        }
        else if next == "'" {
            state = State.EndQuote
        }
        else if line!.value == nil {
            line!.value = next
        }
        else {
            line!.value! = line!.value! + next
        }
        
        return line
    }
    
    private func readEndQuote(line: Line?) throws -> Line? {
        if whitespace() {
            // ignore
        }
        else if next == ";" {
            state = State.Push
        }
        else if peek("@if") {
            values.removeAtIndex(0)
            values.removeAtIndex(0)
            
            state = State.IfDirective
        }
        else {
            throw ReparoError.InvalidConfigurationLine("Unexpected character after quoted value: \(next) \(lineNumber)")
        }
        
        return line
    }
    
    private func peek(input: String) -> Bool {
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
    
    private func whitespace() -> Bool {
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
    
    private func newline() -> Bool {
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
    
    private func whitespaceOrNewLine() -> Bool {
        return whitespace() || newline()
    }
    
    private func nilOrEmpty(value: String?) -> Bool {
        return value == nil || value == ""
    }
    
    private func trim(input: String?) -> String? {
        return input?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
    }
}