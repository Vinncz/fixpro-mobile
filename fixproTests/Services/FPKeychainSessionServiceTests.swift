import Testing
@testable import fixpro

struct FPKeychainSessionServiceTests { 
    
    let sessionService = FPSessionService(storage: FPKeychainQueristService())

    @Test func accessToken() {
        do {
            try? sessionService.removeAccessToken()
            
            var mockAccessToken = "HELLO WORLD"
            
            try sessionService.save(accessToken: mockAccessToken)
            #expect(sessionService.accessToken == nil)
            
            try sessionService.populateAccessToken()
            #expect(sessionService.accessToken == mockAccessToken)
            
            mockAccessToken = "このちわこの世界！"
            try sessionService.removeAccessToken()
            try sessionService.save(accessToken: mockAccessToken)
            try sessionService.populateAccessToken()
            #expect(sessionService.accessToken == mockAccessToken)
            
            try sessionService.removeAccessToken()
            #expect(sessionService.accessToken == nil)
            
        } catch {
            FPLogger.log(tag: .error, error)
            #expect(true==false)
            
        }
    }
    
    @Test func refreshToken() {
        do {
            try? sessionService.removeRefreshToken()
            
            var mockAccessToken = "HELLO WORLD"
            
            try sessionService.save(refreshToken: mockAccessToken)
            #expect(sessionService.refreshToken == nil)
            
            try sessionService.populateRefreshToken()
            #expect(sessionService.refreshToken == mockAccessToken)
            
            mockAccessToken = "このちわこの世界！"
            try sessionService.removeRefreshToken()
            try sessionService.save(refreshToken: mockAccessToken)
            try sessionService.populateRefreshToken()
            #expect(sessionService.refreshToken == mockAccessToken)
            
            try sessionService.removeRefreshToken()
            #expect(sessionService.refreshToken == nil)
            
        } catch {
            FPLogger.log(tag: .error, error)
            #expect(true==false)
            
        }
    }
    
}
