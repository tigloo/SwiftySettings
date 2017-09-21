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

    @IBInspectable open var viewBackgroundColor: UIColor? = UIColor.swiftySettingsDefaultHeaderGray()
    @IBInspectable open var cellBackgroundColor: UIColor? = UIColor.white
    @IBInspectable open var cellTextColor: UIColor? = UIColor.black
    @IBInspectable open var cellSecondaryTextColor: UIColor? = UIColor.darkGray
    @IBInspectable open var tintColor: UIColor? = nil
    @IBInspectable open var separatorColor: UIColor? = UIColor.swiftySettingsDefaultHeaderGray()
    @IBInspectable open var selectionColor: UIColor? = UIColor.lightGray
    @IBInspectable open var forceRoundedCorners: Bool = false

    public struct Appearance {
        let viewBackgroundColor: UIColor?
        let cellBackgroundColor: UIColor?
        let cellTextColor: UIColor?
        let cellSecondaryTextColor: UIColor?
        let tintColor: UIColor?
        let separatorColor: UIColor?
        let selectionColor: UIColor?
        let forceRoundedCorners: Bool
        let statusBarStyle: UIStatusBarStyle

        init(viewBackgroundColor: UIColor? = UIColor.swiftySettingsDefaultHeaderGray(),
             cellBackgroundColor: UIColor? = UIColor.white,
             cellTextColor: UIColor? = UIColor.black,
             cellSecondaryTextColor: UIColor? = UIColor.darkGray,
             tintColor: UIColor? = nil,
             separatorColor: UIColor? = UIColor.swiftySettingsDefaultHeaderGray(),
             selectionColor: UIColor? = UIColor.lightGray,
             forceRoundedCorners: Bool = false,
             statusBarStyle: UIStatusBarStyle = .default) {
            self.viewBackgroundColor = viewBackgroundColor
            self.cellBackgroundColor = cellBackgroundColor
            self.cellTextColor = cellTextColor
            self.cellSecondaryTextColor = cellSecondaryTextColor
            self.tintColor = tintColor
            self.separatorColor = separatorColor
            self.selectionColor = selectionColor
            self.forceRoundedCorners = forceRoundedCorners
            self.statusBarStyle = statusBarStyle
        }

        init(splitVC: SwiftySettingsViewController) {
            self.viewBackgroundColor = splitVC.viewBackgroundColor
            self.cellBackgroundColor = splitVC.cellBackgroundColor
            self.cellTextColor = splitVC.cellTextColor
            self.cellSecondaryTextColor = splitVC.cellSecondaryTextColor
            self.tintColor = splitVC.tintColor
            self.separatorColor = splitVC.separatorColor
            self.selectionColor = splitVC.selectionColor
            self.forceRoundedCorners = splitVC.forceRoundedCorners
            self.statusBarStyle = splitVC.statusBarStyle
        }
    }

    open var statusBarStyle: UIStatusBarStyle = .default

    open var settings: SwiftySettings! {
        didSet{
            self.load(settings.main)
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }

    fileprivate var sections: [Section] = []
    fileprivate var appearance: Appearance
    fileprivate var storedContentInset = UIEdgeInsets.zero
    fileprivate var observerTokens: [NSObjectProtocol] = []
    fileprivate var editingIndexPath: IndexPath? = nil

    var shouldDecorateWithRoundCorners: Bool {
        if self.forceRoundedCorners {
            return true
        }
        return false
    }

    override open var preferredStatusBarStyle: UIStatusBarStyle {
        return self.appearance.statusBarStyle
    }

    public convenience init(settings: SwiftySettings) {
        self.init(nibName: nil, bundle: nil)
        self.settings = settings
    }

    public convenience init (appearance: Appearance, screen: Screen) {
        self.init(nibName: nil, bundle: nil)
        self.appearance = appearance
        self.load(screen)
    }

    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        self.appearance = Appearance(viewBackgroundColor: self.viewBackgroundColor,
                                     cellBackgroundColor: self.cellBackgroundColor,
                                     cellTextColor: self.cellTextColor,
                                     cellSecondaryTextColor: self.cellSecondaryTextColor,
                                     tintColor: self.tintColor,
                                     separatorColor: self.separatorColor,
                                     selectionColor: self.selectionColor,
                                     forceRoundedCorners: self.forceRoundedCorners,
                                     statusBarStyle: self.statusBarStyle)
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    deinit {
        observerTokens.removeAll()
    }

    public required init?(coder aDecoder: NSCoder) {
        self.appearance = Appearance(viewBackgroundColor: self.viewBackgroundColor,
                                     cellBackgroundColor: self.cellBackgroundColor,
                                     cellTextColor: self.cellTextColor,
                                     cellSecondaryTextColor: self.cellSecondaryTextColor,
                                     tintColor: self.tintColor,
                                     separatorColor: self.separatorColor,
                                     selectionColor: self.selectionColor,
                                     forceRoundedCorners: self.forceRoundedCorners,
                                     statusBarStyle: self.statusBarStyle)
        super.init(coder: aDecoder)
    }

    override open func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupKeyboardHandling()
    }

    override open func viewWillAppear(_ animated: Bool) {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }

    func load(_ screen: Screen) {
        self.sections = screen.sections
        self.title = screen.title
    }
}


// MARK: - UITableViewDataSource

extension SwiftySettingsViewController {

    override open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let node = sections[indexPath.section].items[indexPath.row]

        switch (node) {
        case let item as Switch:
            let cell = tableView.dequeueReusableCell(SwitchCell.self, type: .cell)
            cell.appearance = appearance
            cell.load(item)
            return cell
        case let item as TextOnly:
            let cell = tableView.dequeueReusableCell(TextOnlyCell.self, type: .cell)
            cell.appearance = appearance
            cell.load(item)
            return cell
        case let item as Slider:
            let cell = tableView.dequeueReusableCell(SliderCell.self, type: .cell)
            cell.appearance = appearance
            cell.load(item)
            return cell
        case let item as Option:
            let cell = tableView.dequeueReusableCell(OptionCell.self, type: .cell)
            cell.appearance = appearance
            cell.load(item)
            return cell
        case let item as OptionsButton:
            let cell = tableView.dequeueReusableCell(OptionsButtonCell.self, type: .cell)
            cell.appearance = appearance
            cell.load(item)
            return cell
        case let item as Screen:
            let cell = tableView.dequeueReusableCell(SettingsCell.self, type: .cell)
            cell.appearance = appearance
            cell.load(item)
            return cell
        case let item as TextField:
            let cell = tableView.dequeueReusableCell(TextFieldCell.self, type: .cell)
            cell.appearance = appearance
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
        return sections[section].items.count
    }

    override open func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableCell(SectionHeaderFooter.self, type: .header)
        header.appearance = appearance
        header.load(sections[section].title)
        return header
    }

    override open func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if let footerText = sections[section].footer {
            let footer = tableView.dequeueReusableCell(SectionHeaderFooter.self, type: .footer)
            footer.appearance = appearance
            footer.load(footerText)
            return footer
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
        return 22
    }

    override open func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 22
    }

    override open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let node = sections[indexPath.section].items[indexPath.row]

        switch (node) {
        case let item as Screen:
            let vc = SwiftySettingsViewController(appearance: Appearance(splitVC: self), screen: item)
            let nc = self.navigationController
            nc?.pushViewController(vc, animated: true)
        case let item as OptionsButton:
            let screen = Screen(title: item.title) {
                [Section(title: "") { item.options }]
            }
            let vc = SwiftySettingsViewController(appearance: Appearance(splitVC: self), screen: screen)
            self.navigationController?.pushViewController(vc, animated: true)
        case let item as Option:
            item.selected = true
            tableView.reloadData()
            if item.navigateBack {
                let _ = navigationController?.popViewController(animated: true)
                self.tableView.reloadData()
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
}

// MARK: Keyboard handling

extension SwiftySettingsViewController : UITextFieldDelegate {

    func setupKeyboardHandling() {

        let nc = NotificationCenter.default

        observerTokens.append(nc.addObserver(forName: NSNotification.Name.UIKeyboardWillShow, object: nil,
                                             queue: OperationQueue.main) { [weak self] note in

                                                guard self != nil else { return }

                                                guard let userInfo = note.userInfo as? [String: AnyObject],
                                                    let keyboardRect = (userInfo[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue
                                                    else {
                                                        fatalError("Could not extract keyboard CGRect")
                                                }
                                                var contentInsets = UIEdgeInsets(top: 0.0, left: 0.0,
                                                                                 bottom: keyboardRect.size.height, right: 0.0)

                                                if (UIInterfaceOrientationIsPortrait(UIApplication.shared.statusBarOrientation)) {
                                                    contentInsets = UIEdgeInsetsMake(0.0, 0.0, (keyboardRect.size.height), 0.0);
                                                }

                                                self!.storedContentInset = self!.tableView.contentInset

                                                self!.tableView.contentInset = contentInsets;
                                                self!.tableView.scrollIndicatorInsets = contentInsets;

                                                if let scrollToIndexPath = self!.editingIndexPath {
                                                    self!.tableView.scrollToRow(at: scrollToIndexPath,
                                                                                at: .middle,
                                                                                animated:false)
                                                }
        })
        observerTokens.append(nc.addObserver(forName: NSNotification.Name.UIKeyboardWillHide, object: nil,
                                             queue: OperationQueue.main) { [weak self] note in
                                                guard self != nil else { return }

                                                self!.tableView.contentInset = self!.storedContentInset;
                                                self!.tableView.scrollIndicatorInsets = self!.storedContentInset;
        })
    }

    public func textFieldDidBeginEditing(_ textField: UITextField) {
        let point = self.tableView.convert(textField.bounds.origin, from:textField)
        self.editingIndexPath = self.tableView.indexPathForRow(at: point)
    }

    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}



//MARK: Private

private extension SwiftySettingsViewController {
    
    func setupTableView() {
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorInset = UIEdgeInsets.zero;
        tableView.estimatedRowHeight = 100
        tableView.estimatedSectionHeaderHeight = 22
        tableView.rowHeight = UITableViewAutomaticDimension
        
        // Configure appearance
        tableView.backgroundColor = appearance.viewBackgroundColor
        tableView.separatorColor = appearance.separatorColor;
        
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
