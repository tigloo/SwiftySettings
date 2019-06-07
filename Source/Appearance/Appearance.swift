import UIKit

public struct Appearance {
    public var tableViewAppearance: TableViewAppearance?
    public var textAppearance: TextAppearance?
    
    private(set) var viewBackgroundColor: UIColor?
    private(set) var tintColor: UIColor?
    private(set) var textInputColor: UIColor?
    private(set) var statusBarStyle: UIStatusBarStyle
    private(set) var enableAccessibility: Bool
    
    public init(tableViewAppearance: TableViewAppearance = TableViewAppearance(),
         textAppearance: TextAppearance = TextAppearance(),
         viewBackgroundColor: UIColor? = .swiftySettingsDefaultHeaderGray(),
         tintColor: UIColor? = nil,
         textInputColor: UIColor? = .gray,
         enableAccessibility: Bool = false,
         statusBarStyle: UIStatusBarStyle = .default) {
        self.tableViewAppearance = tableViewAppearance
        self.textAppearance = textAppearance
        self.viewBackgroundColor = viewBackgroundColor
        self.tintColor = tintColor
        self.textInputColor = textInputColor
        self.enableAccessibility = enableAccessibility
        self.statusBarStyle = statusBarStyle
    }
    
    @discardableResult
    public mutating func withViewBackgroundColor(_ viewBackgroundColor: UIColor) -> Appearance {
        self.viewBackgroundColor = viewBackgroundColor
        return self
    }
    
    @discardableResult
    public mutating func withTintColor(_ tintColor: UIColor) -> Appearance {
        self.tintColor = tintColor
        return self
    }
    
    @discardableResult
    public mutating func withTextInputColor(_ textInputColor: UIColor) -> Appearance {
        self.textInputColor = textInputColor
        return self
    }
    
    @discardableResult
    public mutating func withStatusBarStyle(_ statusBarStyle: UIStatusBarStyle) -> Appearance {
        self.statusBarStyle = statusBarStyle
        return self
    }
    
    @discardableResult
    public mutating func withEnableAccessibility(_ enableAccessibility: Bool) -> Appearance {
        self.enableAccessibility = enableAccessibility
        return self
    }
}

public struct TableViewAppearance {
    private(set) var cellBackgroundColor: UIColor?
    private(set) var separatorColor: UIColor?
    private(set) var selectionColor: UIColor?
    private(set) var forceRoundedCorners: Bool
    private(set) var hideFooter: Bool
    private(set) var headerFooterCellTextColor: UIColor?
    
    public init(cellBackgroundColor: UIColor? = .white,
         separatorColor: UIColor? = .swiftySettingsDefaultHeaderGray(),
         selectionColor: UIColor? = .lightGray,
         forceRoundedCorners: Bool = false,
         hideFooter: Bool = true,
         headerFooterCellTextColor: UIColor? = .darkText) {
        self.cellBackgroundColor = cellBackgroundColor
        self.separatorColor = separatorColor
        self.selectionColor = selectionColor
        self.forceRoundedCorners = forceRoundedCorners
        self.hideFooter = hideFooter
        self.headerFooterCellTextColor = headerFooterCellTextColor
    }
    
    @discardableResult
    public mutating func withCellBackgroundColor(_ cellBackgroundColor: UIColor) -> TableViewAppearance {
        self.cellBackgroundColor = cellBackgroundColor
        return self
    }
    
    @discardableResult
    public mutating func withSeparatorColor(_ separatorColor: UIColor) -> TableViewAppearance {
        self.separatorColor = separatorColor
        return self
    }
    
    @discardableResult
    public mutating func withSelectionColor(_ selectionColor: UIColor) -> TableViewAppearance {
        self.selectionColor = selectionColor
        return self
    }
    
    @discardableResult
    public mutating func withForceRoundedCorners(_ forceRoundedCorners: Bool) -> TableViewAppearance {
        self.forceRoundedCorners = forceRoundedCorners
        return self
    }
    
    @discardableResult
    public mutating func withHideFooter(_ hideFooter: Bool) -> TableViewAppearance {
        self.hideFooter = hideFooter
        return self
    }
    
    @discardableResult
    public mutating func withHeaderFooterCellTextColor(_ headerFooterCellTextColor: UIColor) -> TableViewAppearance {
        self.headerFooterCellTextColor = headerFooterCellTextColor
        return self
    }
}

public struct TextAppearance {
    private(set) var textColor: UIColor?
    private(set) var secondaryTextColor: UIColor?
    private(set) var font: UIFont?
    private(set) var secondaryTextFont: UIFont?
    
    public init(textColor: UIColor = .black,
         secondaryTextColor: UIColor = .darkGray,
         font: UIFont? = UIFont.systemFont(ofSize: 16),
         secondaryTextFont: UIFont? = UIFont.systemFont(ofSize: 10)) {
        self.textColor = textColor
        self.secondaryTextColor = secondaryTextColor
        self.font = font
        self.secondaryTextFont = secondaryTextFont
    }
    
    @discardableResult
    public mutating func withTextColor(_ textColor: UIColor) -> TextAppearance {
        self.textColor = textColor
        return self
    }
    
    @discardableResult
    public mutating func withSecondaryTextColor(_ secondaryTextColor: UIColor) -> TextAppearance {
        self.secondaryTextColor = secondaryTextColor
        return self
    }
    
    @discardableResult
    public mutating func withFont(_ font: UIFont) -> TextAppearance {
        self.font = font
        return self
    }
    
    @discardableResult
    public mutating func withSecondaryTextFont(_ secondaryTextFont: UIFont) -> TextAppearance {
        self.secondaryTextFont = secondaryTextFont
        return self
    }
}
