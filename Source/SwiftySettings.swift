//
//  SwiftySettings.swift
//
//
//  SwiftySettings
//  Created by Tomasz Gebarowski on 07/08/15.
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
import UIKit

public protocol SettingsStorageType {
    
    subscript(key: String) -> Bool? { get set }
    subscript(key: String) -> Float? { get set }
    subscript(key: String) -> Int? { get set }
    subscript(key: String) -> String? { get set }
}


// MARK: - Base

open class TitledNode {
    open let title: String
    open let icon: UIImage?
    open var storage: SettingsStorageType?

    public init (title: String, icon: UIImage? = nil) {
        self.title = title
        self.icon = icon
    }
}

open class Item<T> : TitledNode
{
    open let key: String
    open let defaultValue: T

    open var value: T

    public typealias ValueChanged = (_ key: String, _ value: T) -> Void
    open var valueChanged: ValueChanged?

    public init (key: String, title: String, defaultValue: T, icon: UIImage?,
                 valueChangedClosure: ValueChanged?)
    {
        self.key = key
        self.defaultValue = defaultValue
        self.value = defaultValue
        self.valueChanged = valueChangedClosure
        super.init(title: title, icon: icon)
    }
}

// MARK: - Sections

open class Section : TitledNode {

    open var items: [TitledNode] = []
    open var footer: String?

    public init(title: String, footer: String? = nil,
                nodesClosure: (() -> [TitledNode])? = nil) {
        super.init(title: title, icon: nil)

        self.footer = footer

        if let closure = nodesClosure {
            items = closure()
        }
    }

    @discardableResult open func with(_ item: TitledNode) -> Section {
        items.append(item)
        return self
    }

    fileprivate func setStorage(_ storage: SettingsStorageType) {
        for item in items {
            item.storage = storage
            if let screen = item as? Screen {
                screen.setStorage(storage)
            } else if let optionButton = item as? OptionsButton {
                optionButton.setStorage(storage)
            }
        }
    }
}

protocol OptionsContainerType: class {
    var key: String {
        get
    }
}

open class OptionsSection : Section, OptionsContainerType {

    let key: String

    public init(key: String, title: String,
                nodesClosure: (() -> [Option])? = nil) {
        self.key = key
        super.init(title: title)

        if let closure = nodesClosure {
            items = closure()
        }
        for item in items {
            if let option = item as? Option {
                option.container = self
            }
        }
    }

    @discardableResult open func with(_ option: Option) -> Section {
        option.container = self
        items.append(option)
        return self
    }
}

// MARK: - Settings

open class OptionsButton : TitledNode, OptionsContainerType {
    var options: [Option] = []
    let key: String

    open var selectedOptionTitle: String {
        get {
            return options.filter { $0.selected }.first?.title ?? ""
        }
    }

    public init(key: String, title: String, icon: UIImage? = nil,
                optionsClosure: (() -> [Option])? = nil) {

        self.key = key
        super.init(title: title, icon: icon)

        if let closure = optionsClosure {
            options = closure()
        }
        for option in options {
                option.navigateBack = true
                option.container = self
        }
    }

    @discardableResult open func with(option: Option) -> OptionsButton {
        option.navigateBack = true
        option.container = self
        options.append(option)
        return self
    }

    fileprivate func setStorage(_ storage: SettingsStorageType) {
        for option in options {
            option.storage = storage
        }
    }
}

open class Screen : TitledNode {
    open var sections: [Section] = []

    public init(title: String, icon: UIImage? = nil, sectionsClosure: (() -> [Section])? = nil) {
        super.init(title: title, icon: icon)

        if let closure = sectionsClosure {
            sections = closure()
        }
    }

    @discardableResult open func include(section: Section) -> Screen {
        sections.append(section)
        return self
    }

    fileprivate func setStorage(_ storage: SettingsStorageType) {
        for section in sections {
            section.storage = storage
            section.setStorage(storage)
        }
    }
}

open class Switch : Item<Bool> {
    public override init(key: String, title: String, defaultValue: Bool = false,
                        icon: UIImage? = nil,
                        valueChangedClosure: ValueChanged? = nil) {
        super.init(key: key, title: title, defaultValue: defaultValue, icon: icon,
                   valueChangedClosure: valueChangedClosure)
    }

    open override var value: Bool {
        get {
            return (storage?[key] as Bool?) ?? defaultValue
        }
        set {
            storage?[key] = newValue
            valueChanged?(key, newValue)
        }
    }
}

open class Option : Item<Int> {

    let optionId: Int
    weak var container: OptionsContainerType!
    var navigateBack = false

    var selected: Bool {
        get {
            let s = (value == optionId)
            return s
        }
        set {
            value = optionId
            valueChanged?(key, optionId)
        }
    }

    public init(title: String, optionId: Int,
                defaultValue: Int = 0, icon: UIImage? = nil,
                valueChangedClosure: ValueChanged? = nil) {

        self.optionId = optionId
        super.init(key: "", title: title, defaultValue: defaultValue, icon: icon,
                   valueChangedClosure: valueChangedClosure)
    }

    open override var value: Int {
        get {
            return (storage?[container.key] as Int?) ?? defaultValue
        }
        set {
            storage?[container.key] = newValue
            valueChanged?(container.key, newValue)
        }
    }
}

open class Slider : Item<Float> {

    var minimumValueImage: UIImage?
    var maximumValueImage: UIImage?
    var minimumValue: Float
    var maximumValue: Float
    var snapToInts: Bool

    public init(key: String, title: String, defaultValue: Float = 0,
                icon: UIImage? = nil,
                minimumValueImage: UIImage? = nil,
                maximumValueImage: UIImage? = nil,
                minimumValue: Float = 0,
                maximumValue: Float = 100,
                snapToInts: Bool = false,
                valueChangedClosure: ValueChanged? = nil)
    {
        self.minimumValue = minimumValue
        self.maximumValue = maximumValue
        self.minimumValueImage = minimumValueImage
        self.maximumValueImage = maximumValueImage
        self.snapToInts = snapToInts

        super.init(key: key, title: title, defaultValue: defaultValue, icon: icon,
                   valueChangedClosure: valueChangedClosure)
    }

    open override var value: Float {
        get {
            return (storage?[key] as Float?) ?? defaultValue
        }
        set {
            storage?[key] = newValue
            valueChanged?(key, newValue)
        }
    }
}

open class TextField : Item<String> {

    let secureTextEntry: Bool

    public init(key: String, title: String, secureTextEntry: Bool = false,
                defaultValue: String = "",
                valueChangedClosure: ValueChanged? = nil)
    {
        self.secureTextEntry = secureTextEntry

        super.init(key: key, title: title, defaultValue: defaultValue, icon: nil,
                   valueChangedClosure: valueChangedClosure)
    }

    open override var value: String {
        get {
            return (storage?[key] as String?) ?? defaultValue
        }
        set {
            storage?[key] = newValue
            valueChanged?(key, newValue)
        }
    }
}

// MARK: - SwiftySettings

open class SwiftySettings {

    open var main: Screen
    open var storage: SettingsStorageType

    public init(storage: SettingsStorageType, title: String,
                sectionsClosure: @escaping () -> [Section]) {
        self.storage = storage
        self.main = Screen(title: title, sectionsClosure: sectionsClosure)

        updateStorageInNodes()
    }

    public init(storage: SettingsStorageType,
                title: String,
                sections: [Section]) {
        self.storage = storage
        self.main = Screen(title: title) {
            sections
        }
        updateStorageInNodes()
    }

    public init(storage: SettingsStorageType, main: Screen) {
        self.storage = storage
        self.main = main
        updateStorageInNodes()
    }
}

private extension SwiftySettings {

    func updateStorageInNodes() {
        for section in main.sections {
            section.setStorage(storage)
        }
    }
}
