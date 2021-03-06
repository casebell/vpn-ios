//
//  AccountProvider.swift
//  PIA VPN
//
//  Created by Davide De Rosa on 12/16/17.
//  Copyright © 2017 London Trust Media. All rights reserved.
//

import Foundation
import PIALibrary
import SwiftyBeaver

private let log = SwiftyBeaver.self

extension AccountProvider {
    
    func retrieveAccount() {
        
        guard self.isLoggedIn else {
            return
        }

        accountInformation({ (info, error) in
            guard let error = error as? ClientError else {
                return
            }
            guard self.isLoggedIn else {
                return
            }
            
            if (error == .unauthorized) {
                log.error("Account: Failed to retrieve the account info, user is unauthorized. Logging out...")
                self.logout(nil)
            }
        })
    }
    
    func refreshAndLogoutUnauthorized(force: Bool = false) {
        
        guard self.isLoggedIn else {
            return
        }

        let migrationDone = Client.preferences.authMigrationSuccess
        var forceRefreshToken = force
        if migrationDone != true {
            forceRefreshToken = true
        }
        
        refreshAccount(force: forceRefreshToken)
        
    }
    
    private func refreshAccount(force forceRefreshToken: Bool) {
        if !forceRefreshToken {
            guard let accountInfo = Client.providers.accountProvider.currentUser?.info else {
                return
            }
            
            guard accountInfo.isExpired else {
                //if not expired we do not need to refresh the token
                return
            }
        }
        
        refreshAccountInfo(force: forceRefreshToken, { (info, error) in
            guard let error = error as? ClientError else {
                return
            }
            guard self.isLoggedIn else {
                return
            }
            
            if (error == .unauthorized) {
                log.error("Account: Failed to refresh account info, user is unauthorized. Logging out...")
                self.logout(nil)
            }
        })

    }
}
