//
//  LiveBool.swift
//  Live
//
//  Created by Anton Heestand on 2018-11-26.
//  Open Source - MIT License
//

import Foundation
import CoreGraphics
#if os(iOS)
import UIKit
#elseif os(macOS)
import Cocoa
#endif
import SwiftUI

//infix operator *%* { precedence 50 }
//infix operator %*% { precedence 60 }
//{ associativity left }

precedencegroup TernaryIf {
    associativity: right
    higherThan: AssignmentPrecedence
    lowerThan: ComparisonPrecedence
}
precedencegroup TernaryElse {
    associativity: left
    higherThan: ComparisonPrecedence
    lowerThan: MultiplicationPrecedence
}

infix operator <?>: TernaryIf
infix operator <=>: TernaryElse

public extension Bool {
    init(_ liveBool: LiveBool) {
        self = liveBool.value
    }
}

@available(iOS 13.0, *)
@available(OSX 10.15, *)
@available(tvOS 13.0, *)
extension LiveBool {
    public var bond: Binding<Bool> {
        var value: Bool = val
        if LiveValues.live {
            _liveValue = { value }
        } else {
            nonLiveValue = value
        }
        return Binding<Bool>(get: {
            self.val
        }, set: { val in
            value = val
        })
    }
}

public class LiveBool: LiveRawValue, ExpressibleByBooleanLiteral, CustomStringConvertible {
    
    public typealias T = Bool
    
    public var name: String?
    
    public let type: Any.Type = Bool.self
    
    public var liveCallbacks: [() -> ()] = []
    
    public var description: String {
        return "live\(name != nil ? "[\(name!)]" : "")(\(Bool(self)))"
    }
    
    public var nonLiveValue: Bool!
    public var _liveValue: (() -> (Bool))!
    public var liveValue: () -> (Bool) {
        guard LiveValues.live else {
            return { self.nonLiveValue }
        }
        return _liveValue
    }
    var value: Bool {
        return liveValue()
    }
    
    public var uniform: Bool {
        uniformCache = value
        return value
    }
    public var uniformIsNew: Bool {
        return uniformCache != value
    }
    var uniformCache: Bool? = nil
    
    public var liveCache: Bool!
    
    public var val: Bool {
        return value
    }
    
    #if os(macOS)
    
    public static var midiAny: LiveBool {
        return LiveBool({ return LiveInt.midiAny.val > 0 })
    }
    
    #endif
    
    public static var darkMode: LiveBool {
        LiveBool({
            #if os(macOS)
            if #available(OSX 10.14, *) {
                return NSApp.effectiveAppearance.name == .darkAqua
            } else {
                return false
            }
            #else
            if #available(iOS 12.0, *) {
                return UIView().traitCollection.userInterfaceStyle == .dark
            } else {
                return false
            }
            #endif
        })
    }
    
    // MARK: - Life Cycle
    
    required public init(_ liveValue: @escaping () -> (Bool)) {
        if LiveValues.live {
            _liveValue = liveValue
        } else {
            nonLiveValue = liveValue()
        }
        checkFuture()
    }
    
    required public init(_ value: Bool) {
        if LiveValues.live {
            _liveValue = { value }
        } else {
            nonLiveValue = value
        }
    }
    
    required public init(booleanLiteral value: BooleanLiteralType) {
        if LiveValues.live {
            _liveValue = { value }
        } else {
            nonLiveValue = value
        }
    }
    
    public init(name: String, value: Bool) {
        self.name = name
        self.name = name
        if LiveValues.live {
            _liveValue = { value }
        } else {
            nonLiveValue = value
        }
    }
    
    // MARK: Equatable
    
    public static func == (lhs: LiveBool, rhs: LiveBool) -> LiveBool {
        return LiveBool({ return Bool(lhs) == Bool(rhs) })
    }
    
    public static func && (lhs: LiveBool, rhs: LiveBool) -> LiveBool {
        return LiveBool({ return Bool(lhs) && Bool(rhs) })
    }
    
    public static func || (lhs: LiveBool, rhs: LiveBool) -> LiveBool {
        return LiveBool({ return Bool(lhs) || Bool(rhs) })
    }
    
    public prefix static func ! (operand: LiveBool) -> LiveBool {
        return LiveBool({ return !Bool(operand) })
    }
    
//    public static func .? (lhs: LiveBool, rhs: LiveBool) -> LiveBool {
//        return lhs //...
//    }
    
    public static func <?> (lhs: LiveBool, rhs: (LiveFloat, LiveFloat)) -> LiveFloat {
        return LiveFloat({ return Bool(lhs) ? CGFloat(rhs.0) : CGFloat(rhs.1) })
    }
    public static func <?> (lhs: LiveBool, rhs: (LiveInt, LiveInt)) -> LiveInt {
        return LiveInt({ return Bool(lhs) ? Int(rhs.0) : Int(rhs.1) })
    }
    public static func <?> (lhs: LiveBool, rhs: (LiveColor, LiveColor)) -> LiveColor {
        return LiveColor({ return Bool(lhs) ? rhs.0._color : rhs.1._color })
    }
    
    #if os(macOS)
    /// find addresses with `MIDI.main.log = true`
    public static func midi(_ address: String) -> LiveBool {
        return LiveBool({ return LiveInt.midi(address).val > 0 })
    }
    #endif
    
}
