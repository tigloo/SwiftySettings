//
//  SettingsSliderCell.swift
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

class TextFieldCell : SettingsCell {

    var item: TextField!
    let titleLabel = UILabel()
    let textField = UITextField()
    weak var textFieldDelegate:UITextFieldDelegate? = nil

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViews()
    }

    override func updateConstraints()
    {
        if !didSetupConstraints {

            textField.translatesAutoresizingMaskIntoConstraints = false
            titleLabel.translatesAutoresizingMaskIntoConstraints = false

            // Title UILabel
            contentView.addConstraints(
                [NSLayoutConstraint(item: titleLabel,
                                    attribute: .leading,
                                    relatedBy: .equal,
                                    toItem: contentView,
                                    attribute: .leading,
                                    multiplier: 1.0,
                                    constant: spacing),
                 NSLayoutConstraint(item: titleLabel,
                                    attribute: .width,
                                    relatedBy: .equal,
                                    toItem: nil,
                                    attribute: .notAnAttribute,
                                    multiplier: 1.0,
                                    constant: 150),
                 NSLayoutConstraint(item: titleLabel,
                                    attribute: .centerY,
                                    relatedBy: .equal,
                                    toItem: contentView,
                                    attribute: .centerY,
                                    multiplier: 1.0,
                                    constant: 0),
                ])
            // UITextField
            let centeringConstraint = NSLayoutConstraint(item: textField,
                                                         attribute:.centerY,
                                                         relatedBy: .equal,
                                                         toItem: contentView,
                                                         attribute: .centerY,
                                                         multiplier: 1.0,
                                                         constant: 0)
            centeringConstraint.priority = UILayoutPriority(900)
            contentView.addConstraints(
                [NSLayoutConstraint(item: textField,
                                    attribute: .leading,
                                    relatedBy: .equal,
                                    toItem: titleLabel,
                                    attribute: .trailing,
                                    multiplier: 1.0,
                                    constant: spacing),
                 NSLayoutConstraint(item: contentView,
                                    attribute: .trailing,
                                    relatedBy: .equal,
                                    toItem: textField,
                                    attribute: .trailing,
                                    multiplier: 1.0,
                                    constant: spacing),
                 NSLayoutConstraint(item: textField,
                                    attribute: .height,
                                    relatedBy: .equal,
                                    toItem: nil,
                                    attribute: .notAnAttribute,
                                    multiplier: 1.0,
                                    constant: 22),
                 centeringConstraint,
                 NSLayoutConstraint(item: contentView,
                                    attribute: .bottom,
                                    relatedBy: .greaterThanOrEqual,
                                    toItem: textField,
                                    attribute: .bottom,
                                    multiplier: 1.0,
                                    constant: spacing)])

            didSetupConstraints = true
        }
        super.updateConstraints()
    }

    override func setupViews() {
        super.setupViews()

        contentView.addSubview(textField)
        contentView.addSubview(titleLabel)

        textLabel?.removeFromSuperview()
        textLabel?.isHidden = true
        imageView?.removeFromSuperview()
        imageView?.isHidden = true

        textField.addTarget(self, action: #selector(TextFieldCell.textInputChanged(_:)),
                            for: .editingChanged)
    }

    override func configureAppearance(_ item: TitledNode) {
        super.configureAppearance(item)

        textField.tintColor = appearance?.tintColor
        textField.textColor = appearance?.textInputColor
        textField.borderStyle = .none
        textField.textAlignment = .right
        textField.isAccessibilityElement = appearance?.enableAccessibility ?? false
        textField.accessibilityTraits = UIAccessibilityTraits.staticText
        self.accessibilityElements?.append(textField)

        titleLabel.font = appearance?.textAppearance?.font
        titleLabel.textColor = appearance?.textAppearance?.textColor
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.7
        titleLabel.isAccessibilityElement = appearance?.enableAccessibility ?? false
        titleLabel.accessibilityTraits = UIAccessibilityTraits.staticText
        self.accessibilityElements?.append(titleLabel)
    }

    func load(_ item: TextField) {
        super.load(item)
        self.item = item

        self.configureAppearance(item)

        self.titleLabel.text = item.title
        self.titleLabel.accessibilityIdentifier = "Textfield_Cell_Label_\(item.key)"
        self.titleLabel.accessibilityLabel = "Textfield Label \(item.title)"

        self.textField.placeholder = item.placeholderText
        self.textField.text = item.value
        self.textField.isSecureTextEntry = item.secureTextEntry
        self.textField.delegate = textFieldDelegate
        self.textField.autocorrectionType = (item.autoCorrection) ? .yes : .no
        self.textField.spellCheckingType = (item.autoCorrection) ? .yes : .no // autoCorrection controls both
        self.textField.isEnabled = !item.disabled
        self.textField.accessibilityIdentifier = "Textfield_Cell_Textfield_\(item.key)"
        self.textField.accessibilityLabel = "Textfield \(item.title) Placeholder \(item.placeholderText) Value \(item.value)"

        self.setNeedsUpdateConstraints()
    }

    @objc func textInputChanged(_ sender: AnyObject) {
        if let text = textField.text {
            item.value = text
        }
    }
}
