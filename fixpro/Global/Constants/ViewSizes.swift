import Foundation

/// A collection of values that represents one axis of a size, in accordance with IBM's Carbon Design System.
indirect enum ViewSize : AssociableWithValue {
    
    /// Represents the an infinitely small size.
    case none
    
    /// Represents 1 point of size in some axis.
    case xxxSmall
    
    /// Represents 2 points of size in some axis.
    case xxSmall
    
    /// Represents 4 points of size in some axis.
    case xSmall
    
    /// Represents 8 points of size in some axis.
    case small
    
    /// Represents 12 points of size in some axis.
    case normal
    
    /// Represents 16 points of size in some axis.
    case medium
    
    /// Represents 20 points of size in some axis.
    case big
    
    /// Represents 24 points of size in some axis.
    case xBig
    
    /// Represents 28 points of size in some axis.
    case xxBig
    
    /// Represents 32 points of size in some axis.
    case xxxBig
    
    /// Represents a customly defined, unchanging value of size.
    case constant  (CGFloat)
    
    /// Represents some sizes put together, resulting in a new value that may not be listed in its source declaration.
    case composite (ViewSize)
    
    var val: CGFloat {
        switch self {
            case .none      : return 0
            case .xxxSmall  : return 1
            case .xxSmall   : return 2
            case .xSmall    : return 4
            case .small     : return 8
            case .normal    : return 12
            case .medium    : return 16
            case .big       : return 20
            case .xBig      : return 24
            case .xxBig     : return 28
            case .xxxBig    : return 32
            case .constant  (let value)   : return value
            case .composite (let spacing) : return spacing.val
        }
    }
    
}

/// Extension for set sizes of icons.
extension ViewSize {
    
    /// Used for sizing icons. Equates to ``ViewSize/medium``.
    static var iCallout: ViewSize = .medium
    
    /// Used for sizing icons. Equates to ``ViewSize/big``.
    static var iBody: ViewSize = .big
    
    /// Used for sizing icons. Equates to ``ViewSize/big`` + ``ViewSize/xxSmall``.
    static var iHeadline: ViewSize = .composite(.big + .xxSmall)
    
    /// Used for sizing icons. Equates to ``ViewSize/xxBig`` + ``ViewSize/xxSmall``.
    static var iTitle: ViewSize = .composite(.xxBig + .xxSmall)
    
    /// Used for sizing icons. Equates to ``ViewSize/xBig`` + ``ViewSize/normal`` + ``ViewSize/xxSmall``.
    static var iLargeTitle: ViewSize = .composite(.xBig + .normal + .xxSmall)
    
}

/// Extensions for set sizes of container breakpoints.
extension ViewSize {
    
    /// Used as width-clamping constants. Equates to 393 points.
    static var cCompact: ViewSize = .constant(393)
    
    /// Used as width-clamping constants. Equates to 768 points.
    static var cLoose: ViewSize = .constant(768)
    
    /// Used as width-clamping constants. Equates to 1080 points.
    static var cWide: ViewSize = .constant(1080)
    
}

extension ViewSize : AdditiveArithmetic {
    
    static var zero: ViewSize {
        return .none
    }
    
    static func + (lhs: ViewSize, rhs: ViewSize) -> ViewSize {
        return .constant(lhs.val + rhs.val)
    }
    
    static func - (lhs: ViewSize, rhs: ViewSize) -> ViewSize {
        return .constant(lhs.val - rhs.val)
    }
    
}

extension ViewSize {
    
    static func * (lhs: ViewSize, rhs: ViewSize) -> ViewSize {
        return .constant(lhs.val * rhs.val)
    }
    
    static func * (lhs: ViewSize, rhs: CGFloat) -> ViewSize {
        return .constant(lhs.val * rhs)
    }
    
    static func / (lhs: ViewSize, rhs: ViewSize) -> ViewSize {
        return .constant(lhs.val / rhs.val)
    }
    
    static func / (lhs: ViewSize, rhs: CGFloat) -> ViewSize {
        return .constant(lhs.val / rhs)
    }
    
}

extension ViewSize : Equatable {
    
    static func == (lhs: ViewSize, rhs: ViewSize) -> Bool {
        return lhs.val == rhs.val
    }
    
    static func != (lhs: ViewSize, rhs: ViewSize) -> Bool {
        return lhs.val != rhs.val
    }
    
}

extension ViewSize : Comparable {
    
    static func < (lhs: ViewSize, rhs: ViewSize) -> Bool {
        return lhs.val < rhs.val
    }
    
    static func > (lhs: ViewSize, rhs: ViewSize) -> Bool {
        return lhs.val > rhs.val
    }
    
    static func <= (lhs: ViewSize, rhs: ViewSize) -> Bool {
        return lhs.val <= rhs.val
    }
    
    static func >= (lhs: ViewSize, rhs: ViewSize) -> Bool {
        return lhs.val >= rhs.val
    }
    
}
