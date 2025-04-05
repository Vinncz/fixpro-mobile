import Foundation

protocol Proxy<T> {
    
    
    /// The type of the backing object.
    /// This is used to determine the type of the object that is being proxied.
    associatedtype T
    
    
    /// The instance (or lack thereof) of the backing object.
    var backing: T? { get }
    
    
    /// Populates the backing object with the given value.
    func populate(with value: T) -> Void
    
    
    /// Depopulates the backing object.
    func depopulate() -> Void
    
}

extension Proxy {
    
    
    /// The type of the backing object.
    /// This is used to determine the type of the object that is being proxied.
    var backingType: T.Type {
        return T.self
    }
    
    
    /// The state of the proxy.
    var isActive: Bool {
        return backing != nil
    }
    
}


class ProxyObject<T>: Proxy {
    
    
    /// The instance (or lack thereof) of the backing object.
    var backing: T?
    
    
    /// Populates the backing object with the given value.
    func populate(with value: T) -> Void {
        backing = value
    }
    
    
    /// Depopulates the backing object.
    func depopulate() -> Void {
        backing = nil
    }
    
}
