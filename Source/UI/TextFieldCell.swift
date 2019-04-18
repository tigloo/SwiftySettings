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

class TextFieldCell: SettingsCell {

    var item: TextField!
    let titleLabel = UILabel()
    let textField = UITextField()
    weak var textFieldDelegate: UITextFieldDelegate? = nil

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


            // Title UILabel/TextField UITextField Constraints
            contentView.addConstraints([NSLayoutConstraint(item: contentView,
                                                           attribute: .centerY,
                                                           relatedBy: .equal,
                                                           toItem: textField,
                                                           attribute: .centerY,
                                                           multiplier: 1.0,
                                                           constant: 0.0),
                                           NSLayoutConstraint(item: titleLabel,
                                                              attribute: .leading,
                                                              relatedBy: .equal,
                                                              toItem: contentView,
                                                              attribute: .leading,
                                                              multiplier: 1.0,
                                                              constant: 10),
                                           NSLayoutConstraint(item: titleLabel,
                                                              attribute: .width,
                                                              relatedBy: .lessThanOrEqual,
                                                              toItem: nil,
                                                              attribute: .notAnAttribute,
                                                              multiplier: 1.0,
                                                              constant: ((titleLabel.superview?.frame.width)! / 4)),
                                           NSLayoutConstraint(item: contentView,
                                                              attribute: .centerY,
                                                              relatedBy: .equal,
                                                              toItem: titleLabel,
                                                              attribute: .centerY,
                                                              multiplier: 1.0,
                                                              constant: 0.0),
                                           NSLayoutConstraint(item: textField,
                                                              attribute: .trailing,
                                                              relatedBy: .equal,
                                                              toItem: contentView,
                                                              attribute: .trailing,
                                                              multiplier: 1.0,
                                                              constant: -10),
                                           NSLayoutConstraint(item: textField,
                                                              attribute: .leading,
                                                              relatedBy: .equal,
                                                              toItem: titleLabel,
                                                              attribute: .trailing,
                                                              multiplier: 1.0,
                                                              constant: 10)])

            didSetupConstraints = true
        }
        super.updateConstraints()
    }

    override func setupViews() {
        super.setupViews()

        contentView.addSubview(textField)
        contentView.addSubview(titleLabel)

        textLabel?.removeFromSuperview()
        imageView?.removeFromSuperview()

        textField.addTarget(self, action: #selector(TextFieldCell.textInputChanged(_:)),
                            for: .editingChanged)
    }

    override func configureAppearance() {
        super.configureAppearance()

        textField.tintColor = appearance?.tintColor
        textField.borderStyle = .none

        titleLabel.textColor = appearance?.cellTextColor
        titleLabel.numberOfLines = 1;
        titleLabel.minimumScaleFactor = 0.7;
        titleLabel.adjustsFontSizeToFitWidth = true;
    }

    func load(_ item: TextField) {
        self.item = item

        self.titleLabel.text = item.title
        self.textField.text = item.value
        self.textField.keyboardType = item.keyboardType
        self.textField.autocapitalizationType = item.autoCapitalize ? .sentences : .none
        self.textField.autocorrectionType = item.autoCapitalize ? .yes : .no
        self.textField.isSecureTextEntry = item.secureTextEntry
        self.textField.placeholder = item.placeholder
        self.textField.delegate = textFieldDelegate

        self.configureAppearance()
        self.setNeedsUpdateConstraints()
    }

    @objc func textInputChanged(_ sender: AnyObject) {
        if let text = textField.text {
            item.value = text
        }
    }
}
