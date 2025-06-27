import Foundation
import Observation



/// Bridges between ``MemberDetailSwiftUIView`` and the ``MemberDetailInteractor``.
/// The former invokes and access everything listed within; and the latter supplies the implementation.
@Observable class MemberDetailSwiftUIViewModel {
    
    
    var member: FPPerson
    
    
    var didIntendToRemove: Bool = false
    
    
    var didRemove: (() -> Void)?
    
    
    init(member: FPPerson) {
        self.member = member
    }
    
}
