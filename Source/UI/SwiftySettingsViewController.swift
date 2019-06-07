//
//  SwiftySettingsViewController.swift
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

open class SwiftySettingsViewController : UITableViewController {
    
    open var statusBarStyle: UIStatusBarStyle = .default {
        didSet {
            self.appearance.withStatusBarStyle(statusBarStyle)
            self.setNeedsStatusBarAppearanceUpdate()
        }
    }

    open var settings: SwiftySettings! {
        didSet {
            self.load(settings.main)
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    open var appearance: Appearance! {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }

    fileprivate var sections: [Section] = []
    fileprivate var storedContentInset = UIEdgeInsets.zero
    fileprivate var observerTokens: [NSObjectProtocol] = []
    fileprivate var screenTriggeredFromIndexPath: IndexPath?
    fileprivate var editingIndexPath: IndexPath?
    fileprivate var lastVisibleRow: IndexPath?
    fileprivate var currentFirstResponderTextField: UITextField?

    var shouldDecorateWithRoundCorners: Bool {
        if self.appearance.tableViewAppearance?.forceRoundedCorners ?? false {
            return true
        }
        return false
    }

    override open var preferredStatusBarStyle: UIStatusBarStyle {
        return self.appearance.statusBarStyle
    }

    public convenience init(settings: SwiftySettings, appearance: Appearance) {
        self.init(nibName: nil, bundle: nil)
        self.settings = settings
        self.appearance = appearance
    }

    public convenience init(appearance: Appearance, screen: Screen) {
        self.init(nibName: nil, bundle: nil)
        self.appearance = appearance
        self.load(screen)
    }

    private override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    override open func awakeFromNib() {
        super.awakeFromNib()
        setupDefaultAppearance()
    }

    deinit {
        observerTokens.removeAll()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override open func viewDidLoad() {
        super.viewDidLoad()

        self.isAccessibilityElement = false
        
        setupTableView()
        setupKeyboardHandling()
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // If coming back from a screen, make sure to update the cell that "triggered" the presentation of the screen
        if let screenTriggeredFromIndexPath = self.screenTriggeredFromIndexPath {
            self.tableView.reloadRows(at: [screenTriggeredFromIndexPath], with: .automatic)
            self.screenTriggeredFromIndexPath = nil
        }
    }

    override open func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        if let responder = self.currentFirstResponderTextField {
            responder.resignFirstResponder()
            self.currentFirstResponderTextField = nil
        }
    }
    
    override open func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animate(alongsideTransition: { context in
            // Save the visible row position
            self.lastVisibleRow = self.tableView.indexPathsForVisibleRows!.last
            context.viewController(forKey: UITransitionContextViewControllerKey.from)
        }, completion: { context in
            // Scroll to the saved position prior to screen rotate
            if let lastVisibleRow = self.lastVisibleRow {
                self.tableView.scrollToRow(at: lastVisibleRow, at: .middle, animated: false)
            }
        })
    }

    func load(_ screen: Screen) {
        self.sections = screen.sections
        self.title = screen.title

        // The toggle-section must update the settings view
        for section in self.sections where section is ToggleSection {
            (section as! ToggleSection).setToggleUpdateClosure {
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100), execute: {
                    [weak self] in
                    self?.tableView.reloadData()
                })
            }
        }
    }
}


// MARK: - UITableViewDataSource

extension SwiftySettingsViewController {

    override open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = sections[indexPath.section]
        let node = section.items[indexPath.row]

        guard var i_appearance = self.appearance else { return UITableViewCell() }

        switch (node) {
        case let item as Switch:
            let cell = tableView.dequeueReusableCell(SwitchCell.self, type: .cell)
            cell.accessibilityElementsHidden = !i_appearance.enableAccessibility
            if let textAppearanceOverride = item.textAppearanceOverride {
                i_appearance.textAppearance = textAppearanceOverride
            }
            cell.appearance = i_appearance
            cell.load(item)
            return cell
        case let item as TextOnly:
            let cell = tableView.dequeueReusableCell(TextOnlyCell.self, type: .cell)
            cell.accessibilityElementsHidden = !i_appearance.enableAccessibility
            if let textAppearanceOverride = item.textAppearanceOverride {
                i_appearance.textAppearance = textAppearanceOverride
            }
            cell.appearance = i_appearance
            cell.load(item)
            return cell
        case let item as Slider:
            let cell = tableView.dequeueReusableCell(SliderCell.self, type: .cell)
            cell.accessibilityElementsHidden = !i_appearance.enableAccessibility
            if let textAppearanceOverride = item.textAppearanceOverride {
                i_appearance.textAppearance = textAppearanceOverride
            }
            cell.appearance = i_appearance
            cell.load(item)
            return cell
        case let item as Option:
            let cell = tableView.dequeueReusableCell(OptionCell.self, type: .cell)
            cell.accessibilityElementsHidden = !i_appearance.enableAccessibility
            if let textAppearanceOverride = item.textAppearanceOverride {
                i_appearance.textAppearance = textAppearanceOverride
            }
            cell.appearance = i_appearance
            cell.load(item)
            return cell
        case let item as OptionsButton:
            let cell = tableView.dequeueReusableCell(OptionsButtonCell.self, type: .cell)
            cell.accessibilityElementsHidden = !i_appearance.enableAccessibility
            if let textAppearanceOverride = item.textAppearanceOverride {
                i_appearance.textAppearance = textAppearanceOverride
            }
            cell.appearance = i_appearance
            cell.load(item)
            return cell
        case let item as Screen:
            let cell = tableView.dequeueReusableCell(SettingsCell.self, type: .cell)
            cell.accessibilityElementsHidden = !i_appearance.enableAccessibility
            if let textAppearanceOverride = item.textAppearanceOverride {
                i_appearance.textAppearance = textAppearanceOverride
            }
            cell.appearance = i_appearance
            cell.load(item)
            return cell
        case let item as ToggleSection:
            let cell = tableView.dequeueReusableCell(SettingsCell.self, type: .cell)
            cell.accessibilityElementsHidden = !i_appearance.enableAccessibility
            if let textAppearanceOverride = item.textAppearanceOverride {
                i_appearance.textAppearance = textAppearanceOverride
            }
            cell.appearance = i_appearance
            cell.load(item)
            return cell
        case let item as TextField:
            let cell = tableView.dequeueReusableCell(TextFieldCell.self, type: .cell)
            cell.accessibilityElementsHidden = !i_appearance.enableAccessibility
            if let textAppearanceOverride = item.textAppearanceOverride {
                i_appearance.textAppearance = textAppearanceOverride
            }
            cell.appearance = i_appearance
            cell.textFieldDelegate = self
            cell.load(item)
            return cell
        default:
            return UITableViewCell()
        }
    }

    override open func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    override open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let section = sections[section]

        // ToggleSection is handled differently
        if let toggleSection = section as? ToggleSection {
            if toggleSection.isToggled() {
                // Toggled, return all items
                return toggleSection.items.count
            } else {
                // Not toggled, only return the first row
                return 1
            }
        } else {
            return section.items.count
        }
    }

    override open func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableCell(SectionHeaderFooter.self, type: .header)

        guard let i_appearance = self.appearance else { return nil }

        header.appearance = i_appearance
        header.accessibilityElementsHidden = !i_appearance.enableAccessibility
        header.load(sections[section].title)
        return header
    }

    override open func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {

        guard let i_appearance = self.appearance else { return nil }

        if !(i_appearance.tableViewAppearance?.hideFooter ?? false) {
            if let footerText = sections[section].footer  {
                let footer = tableView.dequeueReusableCell(SectionHeaderFooter.self, type: .footer)
                footer.appearance = i_appearance
                footer.accessibilityElementsHidden = !i_appearance.enableAccessibility
                footer.load(footerText)
                return footer
            }
        }
        return nil
    }
}

//MARK: - UITableViewDelegate

extension SwiftySettingsViewController {

    override open func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        let node = sections[indexPath.section].items[indexPath.row]

        switch(node) {
        case _ as Screen: fallthrough
        case _ as OptionsButton: fallthrough
        case _ as Option: return true
        case let item as TextOnly: return item.clickable
        default: return false
        }
    }

    override open func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 64
    }

    override open func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {

        guard let i_appearance = self.appearance else { return CGFloat.leastNormalMagnitude }

        if i_appearance.tableViewAppearance?.hideFooter ?? false {
            return CGFloat.leastNormalMagnitude
        }
        return 44
    }

    override open func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    override open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let node = sections[indexPath.section].items[indexPath.row]

        switch (node) {
        case let item as Screen:
            let vc = SwiftySettingsViewController(appearance: self.appearance, screen: item)
            self.screenTriggeredFromIndexPath = indexPath
            self.navigationController?.pushViewController(vc, animated: true)
        case let item as OptionsButton:
            let screen = Screen(title: item.title) {
                [Section(title: item.subTitle ?? "") { item.options }]
            }
            let vc = SwiftySettingsViewController(appearance: self.appearance, screen: screen)
            self.screenTriggeredFromIndexPath = indexPath
            self.navigationController?.pushViewController(vc, animated: true)
        case let item as Option:
            item.selected = true
            // Refresh the current section to display the newly selected option
            tableView.reloadSections([indexPath.section], with: .automatic)
            if item.navigateBack {
                let _ = navigationController?.popViewController(animated: true)
            }
        default:
            break
        }

        DispatchQueue.main.async {
            node.onClicked?()
        }

        tableView.deselectRow(at: indexPath, animated: true)
    }

    override open func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell,
                                 forRowAt indexPath: IndexPath) {

        if shouldDecorateWithRoundCorners {
            let itemCount = sections[indexPath.section].items.count

            if itemCount == 1 {
                decorateCellWithRoundCorners(cell, roundingCorners: [.allCorners])
            } else if indexPath.row == 0 {
                decorateCellWithRoundCorners(cell, roundingCorners: [.topLeft, .topRight])
            } else if indexPath.row == itemCount - 1 {
                decorateCellWithRoundCorners(cell, roundingCorners: [.bottomLeft, .bottomRight])
            }

            if let settingsCell = cell as? SettingsCell {
                settingsCell.inset = 20
            }
        }
    }

    override open func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if let responder = self.currentFirstResponderTextField {
            responder.resignFirstResponder()
            self.currentFirstResponderTextField = nil
        }
    }

    func decorateCellWithRoundCorners(_ cell: UITableViewCell,
                                      roundingCorners corners: UIRectCorner) {
        let maskPath = UIBezierPath(roundedRect: cell.bounds,
                                    byRoundingCorners:  corners ,
                                    cornerRadii: CGSize(width: 5.0, height: 5.0))
        let shapeLayer = CAShapeLayer()
        shapeLayer.frame = cell.bounds
        shapeLayer.path = maskPath.cgPath
        cell.layer.mask = shapeLayer
        cell.clipsToBounds = true
    }
}

// MARK: Keyboard handling

extension SwiftySettingsViewController : UITextFieldDelegate {

    func setupKeyboardHandling() {

        let nc = NotificationCenter.default

        observerTokens.append(nc.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil,
                                             queue: OperationQueue.main) { [weak self] note in
                                                guard let wSelf = self else { return }

                                                if let scrollToIndexPath = wSelf.editingIndexPath {
                                                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(10), execute: {
                                                        wSelf.tableView.scrollToRow(at: scrollToIndexPath,
                                                                                    at: .middle,
                                                                                    animated:false)
                                                    })
                                                }
        })
    }

    public func textFieldDidBeginEditing(_ textField: UITextField) {
        self.currentFirstResponderTextField = textField
        let point = self.tableView.convert(textField.bounds.origin, from:textField)
        self.editingIndexPath = self.tableView.indexPathForRow(at: point)
    }

    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        self.currentFirstResponderTextField = nil
        return true
    }
}



//MARK: Private

private extension SwiftySettingsViewController {
    
    func setupDefaultAppearance() {
        self.appearance = Appearance()
    }
    
    func setupTableView() {

        guard let i_appearance = self.appearance else { return }
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorInset = UIEdgeInsets.zero;
        tableView.estimatedRowHeight = 100
        tableView.estimatedSectionHeaderHeight = 44
        tableView.rowHeight = UITableView.automaticDimension

        tableView.keyboardDismissMode = .interactive
        
        extendedLayoutIncludesOpaqueBars = true
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .always
        } else {
            self.automaticallyAdjustsScrollViewInsets = true
        }
        
        // Configure appearance
        tableView.backgroundColor = i_appearance.viewBackgroundColor
        tableView.separatorColor = i_appearance.tableViewAppearance?.separatorColor

        tableView.registerClass(SwitchCell.self, type: .cell)
        tableView.registerClass(SliderCell.self, type: .cell)
        tableView.registerClass(OptionCell.self, type: .cell)
        tableView.registerClass(OptionsButtonCell.self, type: .cell)
        tableView.registerClass(TextOnlyCell.self, type: .cell)
        tableView.registerClass(SettingsCell.self, type: .cell)
        tableView.registerClass(TextFieldCell.self, type: .cell)
        tableView.registerClass(SectionHeaderFooter.self, type: .header)
        tableView.registerClass(SectionHeaderFooter.self, type: .footer)
    }
}
