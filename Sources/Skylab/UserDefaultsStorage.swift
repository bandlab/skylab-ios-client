//
//  UserDefaultsStorage.swift
//  Skylab
//
//  Copyright © 2020 Amplitude. All rights reserved.
//

import Foundation

class UserDefaultsStorage: Storage {
    let userDefaults = UserDefaults.standard
    let sharedPrefsKey: String
    let sharedPrefsPrefix = "com.amplitude.flags.cached."
    private var map: [String:Variant] = [:]
    private let mapLock = NSLock()

    init(apiKey: String) {
        sharedPrefsKey = sharedPrefsPrefix + apiKey
    }

    func put(key: String, value: Variant) -> Variant? {
        mapLock.withCriticalScope {
            let oldValue = map[key]
            map[key] = value
            return oldValue
        }
    }

    func get(key: String) -> Variant? {
        mapLock.withCriticalScope {
            return map[key]
        }
    }

    func clear() {
        mapLock.withCriticalScope {
            map = [:]
        }
    }

    func getAll() -> [String:Variant] {
        mapLock.withCriticalScope {
            return map
        }
    }

    func load() {
        mapLock.withCriticalScope {
            if
                let data = userDefaults.value(forKey: self.sharedPrefsKey) as? Data,
                let loaded = try? JSONDecoder().decode([String:Variant].self, from: data) {
                for (key, value) in loaded {
                    map[key] = value
                }
                return
            }

            if
                let loaded = userDefaults.dictionary(forKey: self.sharedPrefsKey) as? [String:String] {
                for (key, value) in loaded {
                    map[key] = Variant(value)
                }
                return
            }
        }
    }

    func save() {
        mapLock.withCriticalScope {
            if let data = try? JSONEncoder().encode(map) {
                userDefaults.set(data, forKey: self.sharedPrefsKey)
            }
        }
    }


}

private extension NSLock {
    func withCriticalScope<T>(_ block: () -> T) -> T {
        lock()
        let value = block()
        unlock()
        return value
    }
}
