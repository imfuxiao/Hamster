//
//  RimeNotition.swift
//  HamsterApp
//
//  Created by morse on 7/3/2023.
//

import Foundation
import LibrimeKit

// TODO
class HamsterRimeNotification: IRimeNotificationDelegate {
    func onDelployStart() {
        print("HamsterRimeNotification: onDelployStart")
    }
    
    func onDeploySuccess() {
        print("HamsterRimeNotification: onDeploySuccess")
    }
    
    func onDeployFailure() {
        print("HamsterRimeNotification: onDeployFailure")
    }
    
    func onChangeMode(_ mode: String) {
        print("HamsterRimeNotification: onChangeMode, mode: ", mode)
    }
    
    func onLoadingSchema(_ schema: String) {
        print("HamsterRimeNotification: onLoadingSchema, schema: ", schema)
    }
}
