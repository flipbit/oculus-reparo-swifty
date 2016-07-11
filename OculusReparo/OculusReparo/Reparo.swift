//
//  OculusReparo.swift
//  OculusReparo
//
//  Created by Chris on 06/07/2016.
//  Copyright © 2016 flipbit.co.uk. All rights reserved.
//

import Foundation
import UIKit

public protocol ReparoConfigurationTransform {
    func transform(lines: [Reparo.Line], parser: Reparo.Parser) throws -> [Reparo.Line]
}

public protocol ReparoConfigurationReader {
    func readConfigurationFile(filename: String) throws -> String?
    
    func readIncludeFile(filename: String) throws -> String?
}

public class Reparo {
    enum ReparoError: ErrorType {
        case InvalidConfigurationLine(String)
        case InvalidColorString(String)
        case MissingConfigurationFile(String)
        case RecursiveIncludeDetected
    }
    
    public class Directive {
        var name: String
        var not: Bool

        init(name: String) {
            self.name = name
            self.not = false
        }

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
        var visible: Bool
        var parent: Section?
        public var index: Int
        
        public var isASection: Bool {
            return false
        }
        
        init(filename: String, lineNumber: Int) {
            directives = []
            visible = true
            index = 0
            
            self.filename = filename
            self.lineNumber = lineNumber
        }
        
        public var sections: [Section] {
            return []
        }
        
        public var path: String {
            if (parent != nil) {
                return parent!.path + "/\(key!)[\(index)]"
            }
            else if key == nil {
                return "/"
            }
            
            return "/\(key!)[\(index)]"
        }
    }
    
    public class Section : Line {
        private var _lines: [Line]
        
        public var lines: [Line] {
            set { _lines = newValue }
            get { return _lines.filter { line in line.visible == true } }
        }
        
        override public var isASection: Bool {
            return true
        }
        
        init(line: Line)
        {
            _lines = []
            
            super.init(filename: line.filename, lineNumber: line.lineNumber)
            
            key = line.key
            value = line.value
            directives.appendContentsOf(line.directives)
            visible = line.visible
        }
        
        init(filename: String)
        {
            _lines = []
            
            super.init(filename: filename, lineNumber: 0)
        }
        
        init(filename: String, lines: [Line])
        {
            _lines = lines
            
            super.init(filename: filename, lineNumber: 0)
        }
        
        override public var sections: [Section] {
            var results: [Section] = []
            
            for line in lines {
                if line.visible {
                    if let section = line as? Section {
                        results.append(section)
                    }
                }
            }
            
            return results
        }
        
        func getValue(name: String) -> String? {
            return getValue(name, ifMissing: nil)
        }
        
        func getValue(name: String, ifMissing: String?) -> String? {
            for line in lines {
                if line.visible {
                    if line.key == name {
                        return line.value
                    }
                }
            }
            return ifMissing
        }

        func getFloat(name: String, ifMissing: Float) -> Float {
            let value = getValue(name, ifMissing: String(ifMissing))
            
            return toFloat(value)
        }
        
        func getCGFloat(name: String, ifMissing: CGFloat) -> CGFloat {
            let value = getValue(name, ifMissing: String(ifMissing))
            
            return toCGFloat(value)
        }

        func getUIColor(name: String) throws -> UIColor? {
            return try getUIColor(name, ifMissing: UIColor.clearColor())
        }

        func getUIColor(name: String, ifMissing: UIColor?) throws -> UIColor? {
            if let value = getValue(name) {
                return try toUIColor(value)
            }

            return ifMissing
        }
        
        func getCGColor(name: String) throws -> CGColor? {
            return try getUIColor(name, ifMissing: UIColor.clearColor())?.CGColor
        }
        
        func getCGColor(name: String, ifMissing: UIColor?) throws -> CGColor? {
            if let value = getValue(name) {
                return try toUIColor(value).CGColor
            }
            
            return ifMissing?.CGColor
        }
        
        public func getSection(name: String) -> Section? {
            return getSection(name, recurse: false)
        }
        
        public func getSection(name: String, recurse: Bool) -> Section? {
            var results = getSections(name, recurse: recurse)
            
            if results.count > 0 {
                return results[0]
            } else {
                return nil
            }
        }
        
        public func getSections(name: String) -> [Section] {
            return getSections(name, recurse: false)
        }
        
        public func getSections(name: String, recurse: Bool) -> [Section] {
            return getSections(name, recurse: recurse, search: lines)
        }
        
        private func getSections(name: String, recurse: Bool, search: [Line]) -> [Section] {
            var results: [Section] = []
            
            for line in search {
                if line.visible {
                    if let section = line as? Section {
                        if (section.key == name) {
                            results.append(section)
                        }
                    
                        if recurse {
                            let children = getSections(name, recurse: recurse, search: section.lines)
                        
                            results.appendContentsOf(children)
                        }
                    }
                }
            }
            
            return results
        }
        
        private func toFloat(input: String?) -> Float {
            if input != nil {
                if let n = NSNumberFormatter().numberFromString(input!) {
                    return Float(n)
                }
            }
            
            return Float(0)
        }
        
        private func toCGFloat(input: String?) -> CGFloat {
            if input != nil {
                if let n = NSNumberFormatter().numberFromString(input!) {
                    return CGFloat(n)
                }
            }
            
            return CGFloat(0)
        }
        
        private func toUIColor(input: String?) throws -> UIColor {
            if (input == nil) {
                return UIColor.clearColor()
            }
            
            let hex = input!.stringByTrimmingCharactersInSet(NSCharacterSet.alphanumericCharacterSet().invertedSet)
            var int = UInt32()
            NSScanner(string: hex).scanHexInt(&int)
            let a, r, g, b: UInt32
            switch hex.characters.count {
            case 3: // RGB (12-bit)
                (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
            case 6: // RGB (24-bit)
                (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
            case 8: // ARGB (32-bit)
                (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
            default:
                throw ReparoError.InvalidColorString("\(input!) is an invalid hex color string.")
            }
            
            return UIColor(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
        }
    }
    
    public class Document : Section {
        override public var path: String {
            return ""
        }
    }
    
    /**
        Parser to read Reparo configuration files
    */
    public class Parser {
        var directives: [String]
        var transforms: [ReparoConfigurationTransform]
        var reader: ReparoConfigurationReader
        
        init() {
            directives = []
            transforms = []
            
            transforms.append(IncludeTransform())
            transforms.append(VariableTransform())
            transforms.append(DirectiveTransform())
            
            reader = BundleConfigurationReader()
        }
        
        convenience init(reader: ReparoConfigurationReader) {
            self.init()
            
            self.reader = reader
        }
        
        /**
         Parses the given string into a configuration document
         
         - Parameter input:      The string to parse
         - Parameter filename:   The filename of the string being parsed
         
         - Throws:               Reparo.InvalidConfigurationLine if the configuration is invalid
         
         - Returns:              A configuration document object
         */
        public func parseString(input: String, filename: String) throws -> Document {
            return try parseString(input, filename: filename, runTransforms: true)
        }
        
        /**
         Parses the given string into a configuration document
         
         - Parameter input:      The string to parse
         - Parameter filename:   The filename of the string being parsed
         - Parameter transform:  Flag indicating whether to transform the configuration
         
         - Throws:               Reparo.InvalidConfigurationLine if the configuration is invalid
         
         - Returns:              A configuration document object
         */
        public func parseString(input: String, filename: String, runTransforms: Bool) throws -> Document {
            var document = Document(filename: filename)
            
            let machine = StateMachine(input: input, filename: filename)
            
            var index = 1
            
            while !machine.empty {
                var line = try machine.read()
                
                if line == nil {
                    break
                }
                
                if let section = line as? Section {
                    line = try parseSection(section, machine: machine)
                }
                
                line!.parent = document
                line!.index = index
                
                document.lines.append(line!)
                
                index += 1
            }
            
            if (runTransforms) {
                document = try transform(document)
            }
            
            return document
        }
        
        /**
         Parses the given file into a configuration document
         
         - Parameter filename:  The filename to parse
         
         - Throws:              Reparo.InvalidConfigurationLine if the configuration is invalid
         
         - Returns:             A configuration document object
         */
        public func parseFile(filename: String) throws -> Document {
            return try parseFile(filename, runTransforms: true)
        }
        
        public func parseFile(filename: String, runTransforms: Bool) throws -> Document {
            if let input = try reader.readConfigurationFile(filename) {
                return try parseString(input, filename: filename, runTransforms: runTransforms)
            } else {
                throw ReparoError.MissingConfigurationFile(filename)
            }
        }
        
        public func transform(document: Document) throws -> Document {
            let transformed = document
            for transform in transforms {
                transformed.lines = try transform.transform(transformed.lines, parser: self)
            }
            
            return transformed
        }
        
        private func parseSection(section: Section, machine: StateMachine) throws -> Section {
            var index = 1
            while !machine.empty {
                var line = try machine.read()
                
                if line == nil {
                    break
                }
                
                if let section = line as? Section {
                    line = try parseSection(section, machine: machine)
                }
                
                line!.parent = section
                line!.index = index
                
                section.lines.append(line!)
                index += 1
            }
            
            return section
        }
    }
    
    public class BundleConfigurationReader : ReparoConfigurationReader {
        public func readConfigurationFile(filename: String) throws -> String? {
            let path = getPath(filename)
            return try read(path)
        }
        
        public func readIncludeFile(filename: String) throws -> String? {
            let path = getPath(filename)
            return try read(path)
        }
        
        private func getPath(filename: String) -> String {
            let bundlePath = NSBundle(forClass: self.dynamicType).resourcePath!
            let url = NSURL(fileURLWithPath: bundlePath)
            return url.URLByAppendingPathComponent(filename).path!
        }
        
        private func read(filename: String) throws -> String? {
            return try NSString(contentsOfFile: filename, encoding: NSUTF8StringEncoding) as String
        }
    }
    
    public class VariableTransform : ReparoConfigurationTransform {
        private var variables: [String: String]
        
        init() {
            variables = [String: String]()
        }
        
        public func transform(lines: [Line], parser: Parser) throws -> [Line] {
            for line in lines {
                assign(line)
                line.value = substitute(line.value)
                
                if let section = line as? Section {
                    try transform(section.lines, parser: parser)
                }
            }
            
            return lines
        }
        
        func assign(line: Line) {
            if let key = line.key {
                if key.hasPrefix("@set") && key.characters.count > 5 {
                    var name = key.substringFromIndex(key.startIndex.advancedBy(5))
                    name = name.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
                    if let value = line.value {
                        variables[name] = value
                    }
                }
            }
        }
        
        func substitute(value: String?) -> String? {
            if value != nil {
                for key in variables.keys {
                    if (value! == "@" + key) {
                        return variables[key]
                    }
                }
                
                return value
            }
            
            return nil
        }
    }
    
    public class DirectiveTransform : ReparoConfigurationTransform {
        public func transform(lines: [Line], parser: Parser) throws -> [Line] {
            var transformed: [Line] = []
            for line in lines {
                if line.directives.count > 0 {
                    var include = true
                    
                    for directive in line.directives {
                        let matches = parser.directives.filter { d in d == directive.name }.count
                        
                        include = matches > 0
                        
                        if directive.not {
                            include = !include
                        }
                        
                        if !include {
                            break
                        }
                    }
                    
                    if !include {
                        continue
                    }
                }
                
                if let section = line as? Section {
                    section.lines = try transform(section.lines, parser: parser)
                    
                    transformed.append(section)
                } else {
                    transformed.append(line)
                }
            }
            
            return transformed
        }
    }
    
    public class IncludeTransform : ReparoConfigurationTransform {
        var includeCount = 0
        var includeLimit = 0
        public func transform(lines: [Line], parser: Parser) throws -> [Line] {
            includeCount = 1
            includeLimit = 0
            
            var transformed: [Line] = lines
            while (includeCount > 0) {
                transformed = try expand(transformed, parser: parser)
                
                if (includeLimit > 255) {
                    throw ReparoError.RecursiveIncludeDetected
                }
            }
            
            return transformed
        }
        
        private func expand (lines: [Line], parser: Parser) throws -> [Line] {
            includeCount = 0
            includeLimit = includeLimit + 1
            
            var transformed: [Line] = []

            for line in lines {
                if line.key != nil && line.key!.hasPrefix("@include") {
                    if let filename = line.value {
                        let input = try parser.reader.readIncludeFile(filename)
                        
                        if input == nil {
                            throw ReparoError.MissingConfigurationFile(filename)
                        }
                    
                        let include = try parser.parseString(input!, filename: filename, runTransforms: false)
                    
                        transformed.appendContentsOf(include.lines)
                        
                        includeCount = includeCount + 1
                    }
                } else if let section = line as? Section {
                    section.lines = try expand(section.lines, parser: parser)
                    transformed.append(section)
                } else {
                    transformed.append(line)
                }
            }
            
            return transformed
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