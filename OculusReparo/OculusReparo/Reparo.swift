//
//  OculusReparo.swift
//  OculusReparo
//
//  Created by Chris on 06/07/2016.
//  Copyright © 2016 flipbit.co.uk. All rights reserved.
//

import Foundation

public class Reparo {
    enum ReparoError: ErrorType {
        case InvalidConfigurationLine(String)
    }
    
    public class Directive {
        var name: String
        var not: Bool
        
        init(name: String, not: Bool) {
            self.name = name
            self.not = not
        }
        
        func clone() -> Directive {
            return Directive(name: name, not: not)
        }
    }
    
    public class Line {
        var key: String?
        var value: String?
        var filename: String
        var lineNumber: Int
        var directives: [Directive]
        
        var isASection: Bool {
            return false
        }
        
        init(filename: String, lineNumber: Int) {
            directives = []
            
            self.filename = filename
            self.lineNumber = lineNumber
        }
    }
    
    public class Section : Line {
        override var isASection: Bool {
            return true
        }
        
        init(line: Line)
        {
            super.init(filename: line.filename, lineNumber: line.lineNumber)
            
            key = line.key
            value = line.value
            directives.appendContentsOf(line.directives)
        }
    }
    
    public class Parser {
        public func parseString(input: String, filename: String) throws -> [Line] {
            var lines: [Line] = []
            
            let machine = StateMachine(input: input, filename: filename)
            
            while !machine.empty
            {
                let line = try machine.read()
                
                if line == nil
                {
                    break
                }
                
                if line is Section
                {
                    line = parseSection(line as Section, machine)
                }
                
                lines.append(line)
            }
            
            return lines
        }
        
        private func parseSection(section: Section, machine: StateMachine) throws -> Section {
            
        }
    }
    
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
        }
        
        init(input: String, filename: String) {
            values = input.characters.map { String($0) }
            lineNumber = 1
            state = State.Key
            popState = State.Key
            next = ""
            self.filename = filename
        }
        
        func read() throws -> Line? {
            if (values.count == 0) {
                return nil
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
                
                if (state == State.Push)
                {
                    break
                }
            }

            // Empty data
            if line != nil && line!.key == nil && line!.value == nil
            {
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
            
            return line
        }
        
        var empty: Bool {
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
                    state = State.Push
                    
                    return nil
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
                state = State.DoubleQuote
            }
            
            // Single quote
            else if next == "'" && nilOrEmpty(line?.value) {
                state = State.SingleQuote
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
}