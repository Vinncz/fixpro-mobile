import Foundation

enum DigitalUnit {
    
    case bit, byte
    
    // MARK: -- Base 10 | SI Units
    case kilobit, megabit, gigabit, terabit, petabit
    case kilobyte, megabyte, gigabyte, terabyte, petabyte
    
    // MARK: -- Base 2 | Binary Units
    case kibibit, mebibit, gibibit, tebibit, pebibit
    case kibibyte, mebibyte, gibibyte, tebibyte, pebibyte
    
    var factor: Double {
        switch self {
            // MARK: -- Factors
                case .bit: return 1
                case .byte: return 8
            
            // MARK: -- SI Units • 1000 Multiplers
                case .kilobit: return 1_000
                case .megabit: return 1_000_000
                case .gigabit: return 1_000_000_000
                case .terabit: return 1_000_000_000_000
                case .petabit: return 1_000_000_000_000_000
                
                case .kilobyte: return 8_000 
                case .megabyte: return 8_000_000
                case .gigabyte: return 8_000_000_000
                case .terabyte: return 8_000_000_000_000
                case .petabyte: return 8_000_000_000_000_000
            
            // MARK: -- Binary Units • 1024 Multipliers
                case .kibibit: return 1024
                case .mebibit: return 1024 * 1024
                case .gibibit: return 1024 * 1024 * 1024
                case .tebibit: return 1024 * 1024 * 1024 * 1024
                case .pebibit: return 1024 * 1024 * 1024 * 1024 * 1024
                
                case .kibibyte: return 8192
                case .mebibyte: return 8_388_608 
                case .gibibyte: return 8_589_934_592
                case .tebibyte: return 8_796_093_022_208
                case .pebibyte: return 9_007_199_254_740_992
        }
    }
    
    var symbol: String {
        switch self {
            case .bit: return "b"
            case .byte: return "B"
            case .kilobit: return "kb"
            case .megabit: return "Mb"
            case .gigabit: return "Gb"
            case .terabit: return "Tb"
            case .petabit: return "Pb"
            case .kilobyte: return "kB"
            case .megabyte: return "MB"
            case .gigabyte: return "GB"
            case .terabyte: return "TB"
            case .petabyte: return "PB"
            case .kibibit: return "Kib"
            case .mebibit: return "Mib"
            case .gibibit: return "Gib"
            case .tebibit: return "Tib"
            case .pebibit: return "Pib"
            case .kibibyte: return "KiB"
            case .mebibyte: return "MiB"
            case .gibibyte: return "GiB"
            case .tebibyte: return "TiB"
            case .pebibyte: return "PiB"
        }
    }
    
}

/// Converts the given value from some DigialUnit into a different DigitalUnit.
func digitallyConvert ( _ beforeConversionAmount: Double, from beforeConversionUnit: DigitalUnit, to afterConversionUnit: DigitalUnit ) -> DigitalConversionResult {
    let baseInBits = beforeConversionAmount * beforeConversionUnit.factor
    return DigitalConversionResult (
        initialUnit: beforeConversionUnit, 
        destinationUnit: afterConversionUnit, 
        value: baseInBits / afterConversionUnit.factor
    )
}


struct DigitalConversionResult {
    
    let initialUnit: DigitalUnit
    let destinationUnit: DigitalUnit
    let value: Double
    
    var unitSymbol: String {
        destinationUnit.symbol
    }
    
    func formatted ( precision: Int = 2, withSymbol: Bool = false ) -> String {
        String(format: "%.\(precision)f \(withSymbol ? unitSymbol : "")", value)
    }
    
}


/// Converts the given value to the most reasonable unit. 
func autoConvert ( _ value: Double, from unit: DigitalUnit, useBinary: Bool = false ) -> DigitalConversionResult {
    let baseInBits = value * unit.factor

    let targetUnits: [DigitalUnit] = useBinary
        ? [.byte, .kibibyte, .mebibyte, .gibibyte, .tebibyte, .pebibyte] // Binary (1024)
        : [.byte, .kilobyte, .megabyte, .gigabyte, .terabyte, .petabyte] // SI (1000)

    var bestUnit = targetUnits.first!
    
    for nextUnit in targetUnits {
        let convertedValue = baseInBits / nextUnit.factor
        if convertedValue < 1 { break }
        bestUnit = nextUnit
    }

    return DigitalConversionResult(
        initialUnit: unit,
        destinationUnit: bestUnit,
        value: baseInBits / bestUnit.factor
    )
}
