protocol FPSessionCredentialsManaging {
    func renewAccessToken(withRefreshToken refreshToken: String) throws -> String
    func exchangeForRefreshToken(withAuthorizationCode: String) throws -> String
}
