import Foundation
import VinUtility



typealias FPTextStorageServicing = VUPlacerQuerist<String, String, Bool, FPError> 
                                    & VURemoverQuerist<String, Bool, FPError> 
                                    & VURetrieverQuerist<String, String, FPError>
