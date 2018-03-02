//
//  SettingsOptionButtonCell.swift
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

class OptionsButtonCell : SettingsCell {

    let selectedOptionLabel = UILabel()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        setupViews()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViews()
    }

    override func updateConstraints() {

        if !didSetupConstraints {

            selectedOptionLabel.translatesAutoresizingMaskIntoConstraints = false

            contentView.addConstraints([
                // Spacing Between Title and Selected UILabel
                NSLayoutConstraint(item: selectedOptionLabel,
                                   attribute: .left,
                                   relatedBy: .greaterThanOrEqual,
                                   toItem: textLabel!,
                                   attribute: .right,
                                   multiplier: 1.0,
                                   constant: 15),
                // Selected Option UILabel - Horizontal Constraints
                NSLayoutConstraint(item: contentView,
                                    attribute: .trailing,
                                    relatedBy: .equal,
                                    toItem: selectedOptionLabel,
                                    attribute: .trailing,
                                    multiplier: 1.0,
                                    constant: 5),
                // Selected Option UILabel - Vertical Constraints
                NSLayoutConstraint(item: contentView,
                                   attribute: .centerY,
                                   relatedBy: .equal,
                                   toItem: selectedOptionLabel,
                                   attribute: .centerY,
                                   multiplier: 1.0,
                                   constant: 0)
                ])
        }
        super.updateConstraints()
    }

    override func setupViews() {
        super.setupViews()

        #if swift(>=4.0)
            textLabel?.setContentHuggingPriority(UILayoutPriority.defaultHigh, for: .horizontal)
            selectedOptionLabel.setContentCompressionResistancePriority(UILayoutPriority.defaultHigh, for: .horizontal)
        #elseif swift(>=2.0)
            textLabel?.setContentHuggingPriority(UILayoutPriorityDefaultHigh,
                                                 for: .horizontal)
            selectedOptionLabel.setContentCompressionResistancePriority(UILayoutPriorityDefaultHigh,
                                                                        for: .horizontal)
        #endif

        contentView.addSubview(selectedOptionLabel)
    }

    override func configureAppearance(_ item: TitledNode) {
        super.configureAppearance(item)
        selectedOptionLabel.textColor = appearance?.cellSecondaryTextColor
        selectedOptionLabel.isAccessibilityElement = appearance?.enableAccessibility ?? false
        selectedOptionLabel.accessibilityTraits = UIAccessibilityTraitStaticText
        self.accessibilityElements?.append(selectedOptionLabel)
    }

    func load(_ item: OptionsButton) {
        super.load(item)

        configureAppearance(item)

        self.selectedOptionLabel.text = item.selectedOptionTitle
        self.selectedOptionLabel.accessibilityIdentifier = "Option_Button_Cell_\(item.key))"
        self.selectedOptionLabel.accessibilityLabel = "Option Button \(item.title) Selected Value \(item.selectedOptionTitle)"

        self.accessoryType = .disclosureIndicator

        if let image = item.icon {
            self.imageView?.image = image
        }

        self.isUserInteractionEnabled = !item.disabled

        setNeedsUpdateConstraints()
    }
}
