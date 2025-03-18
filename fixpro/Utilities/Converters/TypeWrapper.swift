import Foundation

/// A type that wraps a value of a specific type. A bunch of this type can be used to create a type-erased collection of values.
enum TypeWrapper<Value> {
    
    /// The wrapped value.
    case wrap (Value)
    
}

extension TypeWrapper {
    
    /// Retrieve the associated value as an instance of specific type (Int, String, etc.)
    /// 
    /// Example:
    /// ```
    /// let config : [Config: TypeWrapper<Any>] = [:]
    /// 
    /// let res = config[.scrollable].take(as: Bool.self) // res is of type Bool?
    /// ```
    func take <RequestedType> ( as type: RequestedType.Type ) -> RequestedType? {
        switch self {
            case .wrap (let val):
                val as? RequestedType
        }
    }
    
    /// Retrieve the associated value as an instance of specific type (Int, String, etc.)
    /// 
    /// Example:
    /// ```
    /// let config : [Config: TypeWrapper<Any>] = [:]
    /// 
    /// let res = config[.scrollable].take(as: [Bool.self]) // res is of type [Bool]?
    /// ```
    func take <RequestedType> ( as type: [RequestedType.Type] ) -> [RequestedType] {
        switch self {
            case .wrap (let vals):
                vals as? [RequestedType] ?? []
        }
    }
    
    /// Retrieve the associated value as an instance of specific type, given the conversion function.
    func take <RequestedType> ( as type: RequestedType.Type, using conversionFunction: (Value) -> RequestedType ) -> RequestedType? {
        switch self {
            case .wrap (let val):
                conversionFunction(val)
        }
    }
    
}

extension TypeWrapper : Equatable where Value : Equatable {
    
    static func == ( lhs: TypeWrapper<Value>, rhs: TypeWrapper<Value> ) -> Bool {
        lhs.take(as: Value.self) == rhs.take(as: Value.self)
    }
    
}
