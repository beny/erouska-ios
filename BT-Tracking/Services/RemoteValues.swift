//
//  RemoteValues.swift
//  BT-Tracking
//
//  Created by Stanislav Kasprik on 29/03/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import Foundation
import FirebaseRemoteConfig

extension AppDelegate {

    func setupFirebaseRemoteConfig() {
        setupDefaultValues()
        fetchRemoteValues()
    }

    private func setupDefaultValues() {
        var remoteDefaults: [String: NSObject] = [:]
        for (key, value) in RemoteValues.defaults {
            guard let object = value as? NSObject else { continue }
            remoteDefaults[key.rawValue] = object
        }

        RemoteConfig.remoteConfig().setDefaults(remoteDefaults)
    }

    private func fetchRemoteValues() {
        #if DEBUG
        let fetchDuration: TimeInterval = 0
        #else
        let fetchDuration: TimeInterval = 3600
        #endif
        RemoteConfig.remoteConfig().fetch(withExpirationDuration: fetchDuration) { _, error in
            if let error = error {
                log("AppDelegate: Got an error fetching remote values \(error)")
                return
            }
            RemoteConfig.remoteConfig().activate()
            log("AppDelegate: Retrieved values from the Firebase Remote Config!")
        }
    }

    func remoteConfigValue(forKey key: RemoteConfigValueKey) -> Any {
        return RemoteConfig.remoteConfig()[key.rawValue]
    }

    func remoteConfigInt(forKey key: RemoteConfigValueKey) -> Int {
        return RemoteConfig.remoteConfig()[key.rawValue].numberValue?.intValue ?? 0
    }

    func remoteConfigString(forKey key: RemoteConfigValueKey) -> String {
        return RemoteConfig.remoteConfig()[key.rawValue].stringValue ?? ""
    }

}

enum RemoteConfigValueKey: String {
    case collectionSeconds
    case waitingSeconds
    case criticalExpositionRssi

    case smsTimeoutSeconds
    case uploadWaitingMinutes
    case persistDataDays

    case faqLink
    case importantLink
    case proclamationLink
    case termsAndConditionsLink
    case aboutLink

    case emergencyNumber
}

struct RemoteValues {

    static let defaults: [RemoteConfigValueKey: Any?] = [
        .collectionSeconds: 120,
        .waitingSeconds: 0,
        .criticalExpositionRssi: -75,

        .smsTimeoutSeconds: 20,
        .uploadWaitingMinutes: 15,
        .persistDataDays: 14,

        .faqLink: "https://koronavirus.mzcr.cz/otazky-a-odpovedi/",
        .importantLink: "https://koronavirus.mzcr.cz",
        .proclamationLink: "https://koronavirus.mzcr.cz",
        .termsAndConditionsLink: "https://koronavirus.mzcr.cz",
        .aboutLink: "http://erouska.cz",

        .emergencyNumber: 1212
    ]

    /// doba scanování v sekundách, default = 120
    static var collectionSeconds: Int {
        return AppDelegate.shared.remoteConfigInt(forKey: RemoteConfigValueKey.collectionSeconds)
    }

    /// doba čekání mezi scany, default = 0
    static var waitingSeconds: Int {
        return AppDelegate.shared.remoteConfigInt(forKey: RemoteConfigValueKey.waitingSeconds)
    }

    /// pro in-app statistiky, úroveň rssi kdy je kontakt nebezpečný, číslo, default = -75
    static var criticalExpositionRssi: Int {
        return AppDelegate.shared.remoteConfigInt(forKey: RemoteConfigValueKey.criticalExpositionRssi)
    }

    /// timeout na automatické ověření SMS, default = 20
    static var smsTimeoutSeconds: TimeInterval {
        return TimeInterval(AppDelegate.shared.remoteConfigInt(forKey: RemoteConfigValueKey.waitingSeconds))
    }

    /// doba mezi uploady, v minutách, číslo, default = 15min
    static var uploadWaitingMinutes: TimeInterval {
        return TimeInterval(AppDelegate.shared.remoteConfigInt(forKey: RemoteConfigValueKey.uploadWaitingMinutes) * 60 * 60)
    }

    /// počet dní, jak dlouho se mají držet data v telefonu, default = 14
    static var persistDataDays: TimeInterval {
        return TimeInterval(AppDelegate.shared.remoteConfigInt(forKey: RemoteConfigValueKey.uploadWaitingMinutes) * 60 * 60 * 24)
    }

    /// odkaz na FAQ - vede z obrazovky Kontakty
    static var faqLink: String {
        return AppDelegate.shared.remoteConfigString(forKey: RemoteConfigValueKey.faqLink)
    }

    /// odkaz na důležité kontakty - vede z obrazovky Kontakty
    static var importantLink: String {
        return AppDelegate.shared.remoteConfigString(forKey: RemoteConfigValueKey.importantLink)
    }

    /// odkaz na prohlášení o podpoře - vede z úvodní obrazovky a z nápovědy
    static var proclamationLink: String {
        return AppDelegate.shared.remoteConfigString(forKey: RemoteConfigValueKey.proclamationLink)
    }

    /// Podminky zpracovan
    static var termsAndConditionsLink: String {
        return AppDelegate.shared.remoteConfigString(forKey: RemoteConfigValueKey.termsAndConditionsLink)
    }

    /// Odkaz na tým
    static var aboutLink: String {
        return AppDelegate.shared.remoteConfigString(forKey: RemoteConfigValueKey.aboutLink)
    }

    /// nouzové číslo - 1212
    static var emergencyPhonenumber: Int {
        return AppDelegate.shared.remoteConfigInt(forKey: RemoteConfigValueKey.emergencyNumber)
    }

}
