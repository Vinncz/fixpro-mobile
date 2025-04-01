protocol FPSessionCredentialsStoring: FPStatefulService {
    
    var accessToken: String? { get }
    var refreshToken: String? { get }
    var authorizationCode: String? { get }
    
    func populateRefreshToken() throws
    func removeRefreshToken() throws
    func save(refreshToken token: String) throws
    
    func populateAccessToken() throws
    func removeAccessToken() throws
    func save(accessToken token: String) throws
    
    func populateAuthorizationCode() throws
    func removeAuthorizationCode() throws
    func save(authorizationCode code: String) throws
    
}
