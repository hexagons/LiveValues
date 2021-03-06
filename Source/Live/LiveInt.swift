//
//  LiveInt.swift
//  Live
//
//  Created by Anton Heestand on 2018-11-26.
//  Open Source - MIT License
//

import Foundation
import CoreGraphics
import SwiftUI

public extension Int {
    init(_ liveInt: LiveInt) {
        self = liveInt.value
    }
}

@available(iOS 13.0, *)
@available(OSX 10.15, *)
@available(tvOS 13.0, *)
extension LiveInt {
    public var bond: Binding<Int> {
        var value: Int = val
        if LiveValues.live {
            _liveValue = { value }
        } else {
            nonLiveValue = value
        }
        return Binding<Int>(get: {
            self.val
        }, set: { val in
            value = val
        })
    }
}

public class LiveInt: LiveRawValue, /*Equatable, Comparable,*/ ExpressibleByIntegerLiteral, CustomStringConvertible {
    
    public typealias T = Int
        
    public var name: String?
    
    public let type: Any.Type = Int.self
    
    public var liveCallbacks: [() -> ()] = []
    
    public var description: String {
        return "live\(name != nil ? "[\(name!)]" : "")(\(value))"
    }
    
    public var nonLiveValue: Int!
    public var _liveValue: (() -> (Int))!
    public var liveValue: () -> (Int) {
        guard LiveValues.live else {
            return { self.nonLiveValue }
        }
        return _liveValue
    }
    var value: Int {
        guard limit else { return liveValue() }
        return Swift.max(Swift.min(liveValue(), max), min)
    }
    
    public var limit: Bool = false
    public var min: Int = 0
    public var max: Int = 1
    public var range: Range<Int> {
        min..<max
    }
    
    public var uniform: Int {
        uniformCache = value
        return value
    }
    public var uniformIsNew: Bool {
        return uniformCache != value
    }
    var uniformCache: Int? = nil
    
    public var liveCache: Int!
    
    public var val: Int {
        return value
    }
    
    #if os(macOS)
    
    public static var midiAny: LiveInt {
        return LiveInt({ () -> (Int) in
            return MIDI.main.firstAnyRaw ?? 0
        })
    }
    
    #endif
    
//    public var year: LiveInt!
//    public var month: LiveInt!
//    public var day: LiveInt!
//    public var hour: LiveInt!
//    public var minute: LiveInt!
//    public var second: LiveInt!
    
    public static var seconds: LiveInt {
        /// access to capture now date
        _ = LiveValues.main
        return LiveInt({ () -> (Int) in
            return Int(LiveValues.main.seconds)
        })
    }
    public static var secondsSince1970: LiveInt {
        /// access to capture now date
        _ = LiveValues.main
        return LiveInt({ () -> (Int) in
            return Int(Date().timeIntervalSince1970)
        })
    }
    
    public static var frameIndex: LiveInt {
        var index: Int = 0
        return LiveInt({ () -> (Int) in
            index += 1
            return index
        })
    }
    
    // MARK: - Life Cycle
    
    required public init(_ liveValue: @escaping () -> (Int)) {
        if LiveValues.live {
            _liveValue = liveValue
        } else {
            nonLiveValue = liveValue()
        }
        checkFuture()
    }
    
    public init(_ liveFloat: LiveFloat) {
        if LiveValues.live {
            _liveValue = { Int(liveFloat.value) }
        } else {
            nonLiveValue = Int(liveFloat.value)
        }
    }
    
    public init(_ value: CGFloat) {
        if LiveValues.live {
            _liveValue = { Int(value) }
        } else {
            nonLiveValue = Int(value)
        }
    }
    
    public required init(_ value: Int) {
        if LiveValues.live {
            _liveValue = { value }
        } else {
            nonLiveValue = value
        }
    }
    
    public init(_ value: Int, min: Int? = nil, max: Int? = nil, limit: Bool = false) {
        if LiveValues.live {
            _liveValue = { value }
        } else {
            nonLiveValue = value
        }
        self.min = min ?? 0
        self.max = max ?? 1
        self.limit = limit
    }
    
    required public init(integerLiteral value: IntegerLiteralType) {
        if LiveValues.live {
            _liveValue = { Int(value) }
        } else {
            nonLiveValue = Int(value)
        }
    }
    
//    public init(name: String, value: Int, min: CGFloat, max: CGFloat) {
//        self.name = name
//        self.min = min
//        self.max = max
//        self.name = name
//        liveValue = { return value }
//    }
    
    // MARK: Equatable
    
    public static func == (lhs: LiveInt, rhs: LiveInt) -> LiveBool {
        return LiveBool({ return lhs.value == rhs.value })
    }
    
//    public static func == (lhs: LiveInt, rhs: Int) -> LiveBool {
//        return lhs.value == rhs
//    }
//    public static func == (lhs: Int, rhs: LiveInt) -> LiveBool {
//        return lhs == rhs.value
//    }
    
    // MARK: Comparable
    
    public static func < (lhs: LiveInt, rhs: LiveInt) -> LiveBool {
        return LiveBool({ return lhs.value < rhs.value })
    }
//    public static func < (lhs: LiveInt, rhs: Int) -> LiveBool {
//        return LiveInt({ return lhs.value < rhs })
//    }
//    public static func < (lhs: Int, rhs: LiveInt) -> LiveBool {
//        return LiveInt({ return lhs < rhs.value })
//    }
    
    // MARK: Operators
    
    public static func + (lhs: LiveInt, rhs: LiveInt) -> LiveInt {
        return LiveInt({ return lhs.value + rhs.value })
    }
    
    public static func - (lhs: LiveInt, rhs: LiveInt) -> LiveInt {
        return LiveInt({ return lhs.value - rhs.value })
    }
    
    public static func * (lhs: LiveInt, rhs: LiveInt) -> LiveInt {
        return LiveInt({ return lhs.value * rhs.value })
    }
//    public static func *= (lhs: inout LiveInt, rhs: LiveInt) {
//        lhs.liveValue = { return lhs.value * rhs.value }
//    }
    
    public static func / (lhs: LiveInt, rhs: LiveInt) -> LiveInt {
        return LiveInt({ return lhs.value / rhs.value })
    }
//    public static func / (lhs: LiveInt, rhs: Int) -> LiveInt {
//        return LiveInt({ return lhs.value / rhs })
//    }
//    public static func / (lhs: Int, rhs: LiveInt) -> LiveInt {
//        return LiveInt({ return lhs / rhs.value })
//    }
    
    public static func <> (lhs: LiveInt, rhs: LiveInt) -> LiveInt {
        return LiveInt({ return Swift.min(lhs.value, rhs.value) })
    }
    
    public static func >< (lhs: LiveInt, rhs: LiveInt) -> LiveInt {
        return LiveInt({ return Swift.max(lhs.value, rhs.value) })
    }
    
    
    public prefix static func - (operand: LiveInt) -> LiveInt {
        return LiveInt({ return -operand.value })
    }
    
    
    public static func <=> (lhs: LiveInt, rhs: LiveInt) -> (LiveInt, LiveInt) {
        return (lhs, rhs)
    }
    
    // MARK: Local Funcs
    
    public static func random(in range: Range<Int>) -> LiveInt {
        return LiveInt(Int.random(in: range))
    }
    public static func random(in range: ClosedRange<Int>) -> LiveInt {
        return LiveInt(Int.random(in: range))
    }
    
    public static func liveRandom(in range: Range<Int>) -> LiveInt {
        return LiveInt({ return Int.random(in: range) })
    }
    public static func liveRandom(in range: ClosedRange<Int>) -> LiveInt {
        return LiveInt({ return Int.random(in: range) })
    }
    
    #if os(macOS)
    public static func midi(_ address: String) -> LiveInt {
        return LiveInt({ return MIDI.main.listRaw[address] ?? 0 })
    }
    #endif
    
}
