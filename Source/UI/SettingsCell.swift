//
//  SettingsCell.swift
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

class SettingsCell : UITableViewCell {

    let spacing: CGFloat = 10
    let height: CGFloat = 44
    var inset: CGFloat = 0
    var appearance: SwiftySettingsViewController.Appearance?
    var leftTitleConstraint: NSLayoutConstraint!
    var leftTitleVerticalConstraint: NSLayoutConstraint!
    var leftSubTitleConstraint: NSLayoutConstraint?
    var leftSubTitleVerticalConstraint: NSLayoutConstraint?
    var didSetupConstraints = false

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.setNeedsLayout()
        contentView.layoutIfNeeded()
    }

    override func updateConstraints() {
        /* Assure that titleLabel and iconView are present and added to contentView */
        guard let titleLabel = textLabel, textLabel?.superview != nil,
              let iconView = imageView, imageView?.superview != nil
        else {
            super.updateConstraints()
            return
        }

        var shouldRecalculateForDetail = false
        if let _ = detailTextLabel, detailTextLabel?.superview != nil, detailTextLabel?.text != nil {
            shouldRecalculateForDetail = true
        }

        if !didSetupConstraints {
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            iconView.translatesAutoresizingMaskIntoConstraints = false

            // Icon UIImageView - Constraints
            contentView.addConstraints(
                // Height Constraint,
                // Vertical Constraint
                [NSLayoutConstraint(item: iconView,
                                    attribute: .centerY,
                                    relatedBy: .equal,
                                    toItem: contentView,
                                    attribute: .centerY,
                                    multiplier: 1.0,
                                    constant: 0),
                // Horizontal Constraint
                NSLayoutConstraint(item: iconView,
                                   attribute: .leading,
                                   relatedBy: .equal,
                                   toItem: contentView,
                                   attribute: .leading,
                                   multiplier: 1.0,
                                   constant: spacing)
                ])

            // Title UILabel - Horizontal Constraint
            leftTitleConstraint = NSLayoutConstraint(item: titleLabel,
                attribute: .leading,
                relatedBy: .equal,
                toItem: contentView,
                attribute: .leading,
                multiplier: 1.0,
                constant: spacing)

            // Title UILabel - Vertical Constraint
            leftTitleVerticalConstraint = NSLayoutConstraint(item: titleLabel,
                                                             attribute: .centerY,
                                                             relatedBy: .equal,
                                                             toItem: contentView,
                                                             attribute: .centerY,
                                                             multiplier: 1.0,
                                                             constant: 0)

            contentView.addConstraints([leftTitleVerticalConstraint, leftTitleConstraint])

            // Check if we need a detail label as well
            if let subTitleLabel = detailTextLabel, detailTextLabel?.superview != nil {
                subTitleLabel.translatesAutoresizingMaskIntoConstraints = false

                let subTitleFontHeight = titleLabel.font.lineHeight

                // Sub-Title UILabel - Horizontal Constraint
                leftSubTitleConstraint = NSLayoutConstraint(item: subTitleLabel,
                                                            attribute: .leading,
                                                            relatedBy: .equal,
                                                            toItem: contentView,
                                                            attribute: .leading,
                                                            multiplier: 1.0,
                                                            constant: spacing)


                // Sub-Title UILabel - Vertical Constraint
                leftSubTitleVerticalConstraint = NSLayoutConstraint(item: subTitleLabel,
                                                                     attribute: .centerY,
                                                                     relatedBy: .equal,
                                                                     toItem: contentView,
                                                                     attribute: .centerY,
                                                                     multiplier: 1.0,
                                                                     constant: subTitleFontHeight / 2)
                contentView.addConstraints([leftSubTitleVerticalConstraint!, leftSubTitleConstraint!])
            }

            let heightConstraint = NSLayoutConstraint(item: contentView,
                attribute: .height,
                relatedBy: .equal,
                toItem: nil,
                attribute: .notAnAttribute,
                multiplier: 1.0,
                constant: height)

            #if swift(>=4.0)
                heightConstraint.priority = UILayoutPriority(rawValue: 999)
            #elseif swift(>=2.0)
                heightConstraint.priority = 999
            #endif
            contentView.addConstraint(heightConstraint)

            didSetupConstraints = true
        }

        let titleFontHeight = titleLabel.font.lineHeight
        leftTitleVerticalConstraint.constant = (shouldRecalculateForDetail) ? -(titleFontHeight/2) : 0
        leftTitleConstraint.constant = iconView.frame.width + spacing
        leftSubTitleConstraint?.constant = iconView.frame.width + spacing

        super.updateConstraints()
    }

    override var frame:CGRect {
        set {
            var f = newValue
            f.origin.x += inset;
            f.size.width -= 2 * inset;
            super.frame = f
        }
        get {
            return super.frame
        }
    }

    func setupViews() {

    }

    func load(_ item: TitledNode) {

        configureAppearance()

        textLabel?.text = item.title

        if item.subTitle != nil {
            detailTextLabel?.text = item.subTitle
        }

        if (item as? Screen != nil) {
            accessoryType = .disclosureIndicator;
        }

        if let image = item.icon {
            imageView?.image = image
        }

        setNeedsUpdateConstraints()
    }

    func configureAppearance() {
        textLabel?.textColor = appearance?.cellTextColor
        detailTextLabel?.textColor = appearance?.cellTextColor
        contentView.backgroundColor = appearance?.cellBackgroundColor
        backgroundColor = appearance?.cellBackgroundColor
        selectedBackgroundView = UIView()
        selectedBackgroundView?.backgroundColor = appearance?.selectionColor
    }
}
