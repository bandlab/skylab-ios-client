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
            do {
                if let data = userDefaults.value(forKey: self.sharedPrefsKey) as? Data {
                    let loaded = try JSONDecoder().decode([String:Variant].self, from: data)
                    for (key, value) in loaded {
                        map[key] = value
                    }
                }
            } catch {
                print("[Experiment] load failed: \(error)")
            }
        }
    }

    func save() {
        mapLock.withCriticalScope {
            do {
                let data = try JSONEncoder().encode(map)
                userDefaults.set(data, forKey: self.sharedPrefsKey)
            } catch {
                print("[Experiment] save failed: \(error)")
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
