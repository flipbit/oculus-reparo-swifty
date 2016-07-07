//
//  OculusReparo.swift
//  OculusReparo
//
//  Created by Chris on 06/07/2016.
//  Copyright © 2016 flipbit.co.uk. All rights reserved.
//

import Foundation

public class OculusReparo {
    func doit() -> String {
        return "Hello"
    }
    
    public class Line {
        var key: String?
        var value: String?
        var number: Int?
    }
    
    public class StateMachine {
        var values: [String]
        var number: Int
        var state: State
        
        enum State {
            case Key
            case Push
        }
        
        init(input: String) {
            values = input.characters.map { String($0) }
            number = 1
            state = State.Key
        }
        
        func read() -> Line? {
            if (values.count == 0) {
                return nil
            }

            var line: Line? = Line()
            line!.number = number
            
            while (values.count > 0)
            {
                let next = values[0]
                values.removeAtIndex(0)
                
                if (next == "\r") {
                    number = number + 1
                    
                    if (line != nil) {
                        if (line!.key != nil && line!.key != "") {
                            line!.number = number
                        }
                    }
                }
                
                switch state {
                case State.Key:
                    line = readKey(line, next: next)
                    break
                default:
                    break
                }
                
                if (state == State.Push)
                {
                    state = State.Key
                    
                    break
                }
            }
            
            return line
        }
        
        func readKey(line: Line?, next: String) -> Line? {
            if (next == ";") {
                state = State.Push
            }
            else if line!.key == nil {
                line!.key = next
            } else {
                line!.key = line!.key! + next
            }
            
            return line
        }
    }
}