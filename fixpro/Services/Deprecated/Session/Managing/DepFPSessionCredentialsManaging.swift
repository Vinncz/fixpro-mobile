protocol DepFPSessionCredentialsManaging {
    func renewAndSaveAccessToken(fromRefreshToken refreshToken: String) throws
    func exchangeAndSaveAccessAndRefreshTokens(fromAuthorizationCode authCode: String) throws
}
