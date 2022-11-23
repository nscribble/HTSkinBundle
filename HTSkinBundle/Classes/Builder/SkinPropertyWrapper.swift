//
//  SkinPropertyWrapper.swift
//  Pods-HTSkinBundle_Example
//
//  Created by Jason on 2022/10/10.
//

import Foundation

public
struct Styler<UIElement> {
    internal let e: UIElement
    
    internal init(_ e: UIElement) {
        self.e = e
    }
}

public
protocol SkinStyleCompatible {
    associatedtype UIElement
    
    var style: Styler<UIElement> { get set }
}

extension SkinStyleCompatible {
    public var style: Styler<Self> {
        get {
            #if DEBUG
            assert(Thread.isMainThread, "⚠️请在主线程进行样式配置")
            #endif
            return Styler<Self>(self)
        }
        set {
            
        }
    }
}

// MARK: -

typealias StylerApplyingClosure = ((_ element: UIView)->Void)
internal extension UIView {
    static let skinBgColorKey: String = "UIView.skinBgColorKey"
    static let skinTextColorKey: String = "UIView.skinTextColorKey"
    static let skinFontColorKey: String = "UIView.skinFontColorKey"
    static let skinImageKey: String = "UIView.skinImageKey"
    static let skinModuleKey: String = "UIView.skinModuleKey"
    static let skinComponentKey: String = "UIView.skinComponentKey"
    static let skinResourceComponentKey: String = "UIView.skinResourceComponentKey"
    
    struct AssociatedKey {
        static var skinBuilderKeys: Void?
        static var skinApplyingKeys: Void?
    }
    
    var skinBuilders: [String: Any] {
        set {
            objc_setAssociatedObject(self, &AssociatedKey.skinBuilderKeys, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            assert(Thread.isMainThread, "⚠️请在主线程配置UI")
            
            if let skinBuilders = objc_getAssociatedObject(self, &AssociatedKey.skinBuilderKeys) as? [String: Any] {
                return skinBuilders
            }
            
            let builders = [String: Any]()
            self.skinBuilders = builders
            return builders
        }
    }
    
    var skinApplyingClosures: [String: StylerApplyingClosure] {
        set {
            objc_setAssociatedObject(self, &AssociatedKey.skinApplyingKeys, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            if let closures = objc_getAssociatedObject(self, &AssociatedKey.skinApplyingKeys) as? [String: StylerApplyingClosure] {
                return closures
            }
            
            let closures = [String: StylerApplyingClosure]()
            self.skinApplyingClosures = closures
            return closures
        }
    }
    
}
