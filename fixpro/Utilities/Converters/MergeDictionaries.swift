import Foundation

/// Merges two dictionaries together. The right-hand argument takes precedence.
func mergeDictionaries<Key, Value> ( _ left: [Key: Value], _ right: [Key: Value]) -> [Key: Value] {
    var result = left
    right.forEach { result[$0.key] = $0.value }
    
    return result
}
