//
//  StorageStub.swift
//
//
//  SwiftySettings
//  Created by Tomasz Gebarowski on 24/08/15.
//  Copyright © 2015 codica Tomasz Gebarowski <gebarowski at gmail.com>.
//  All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

import Foundation
import SwiftyUserDefaults

@testable import SwiftySettings

extension DefaultsKeys {
    static let key1 = DefaultsKey<Bool?>("key1")
    static let key2 = DefaultsKey<Double?>("key2")
    static let key3 = DefaultsKey<Int?>("key3")
    static let key4 = DefaultsKey<Int?>("key4")
}

class StorageStub : SettingsStorageType {
    var data: [String: Any] = [:]
    
    subscript(key: DefaultsKey<Bool?>) -> Bool? {
        get {
            return data[key._key] as? Bool
        }
        set(newValue) {
            if let newValue = newValue {
                data[key._key] = newValue
            }
        }
    }
    
    subscript(key: DefaultsKey<Double?>) -> Double? {
        get {
            return data[key._key] as? Double
        }
        set(newValue) {
            if let newValue = newValue {
                data[key._key] = newValue
            }
        }
    }
    
    subscript(key: DefaultsKey<Int?>) -> Int? {
        get {
            return data[key._key] as? Int
        }
        set(newValue) {
            if let newValue = newValue {
                data[key._key] = newValue
            }
        }
    }
    
    subscript(key: DefaultsKey<String?>) -> String? {
        get {
            return data[key._key] as? String
        }
        set(newValue) {
            if let newValue = newValue {
                data[key._key] = newValue
            }
        }
    }
}
