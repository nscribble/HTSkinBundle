//
//  Skin+UIElement.swift
//  HTSkinBundle
//
//  Created by Jason on 2022/10/11.
//

import Foundation
import UIKit

// MARK: - StylerApplying

class StylerApplying {
    static let closureKeyModuleNameDefault = "m"
    static let closureKeyComponentNameDefault = "c"
    
    static let shared: StylerApplying = StylerApplying()
    private var elements: [String: NSHashTable<AnyObject>] = [:]
    private var closures: [String: StylerApplyingClosure] = [:]
    
    func update(element: UIView, key: String, applying: @escaping ((_ element: UIView)->Void)) {
        let module = element.style.module
        let component = element.style.component
        let closureKey = closureKeyForModule(module, component: component, key: key)
        
        element.skinApplyingClosures[closureKey] = applying
        addElement(element, for: closureKey)
        
        applying(element)
    }
    
    func addElement(_ element: UIView, for closureKey: String) {
        if let hashTable = self.elements[closureKey] {
            hashTable.add(element)
            return
        }
        
        let hashTable = NSHashTable<AnyObject>(options: .weakMemory)
        self.elements[closureKey] = hashTable
        hashTable.add(element)
    }
    
    func closureKeyForModule(_ module: String?, component: String?, key: String) -> String {
        let closureKey = "skin_\(module ?? StylerApplying.closureKeyModuleNameDefault)_\(component ?? StylerApplying.closureKeyComponentNameDefault)_\(key)"
        return closureKey
    }
    
    func refreshAll() {
        self.elements.forEach { (key: String, hashTable: NSHashTable<AnyObject>) in
            hashTable.allObjects.forEach { element in
                guard let element = element as? UIView,
                      let closure = element.skinApplyingClosures[key] else {// UIElement
                    return
                }
                
                closure(element)
            }
        }
    }
    
    func refresh(module: String?, component: String?, key: String) {
        let closureKey = closureKeyForModule(module, component: component, key: key)
        refresh(closureKey)
    }
    
    private
    func refresh(_ closureKey: String) {
        guard let hashTable = self.elements[closureKey] else {
            return
        }
        
        hashTable.allObjects.forEach { element in
            guard let element = element as? UIView,
                  let closure = element.skinApplyingClosures[closureKey] else {// UIElement
                return
            }
            
            closure(element)
        }
    }
}

// MARK: - Styler for SkinStyleCompatible

extension UIView: SkinStyleCompatible {}

internal
extension Styler where UIElement: UIView {
    var module: String? {
        return self.e.skinBuilders[UIView.skinModuleKey] as? String
    }
    
    var component: String? {
        return self.e.skinBuilders[UIView.skinComponentKey] as? String
    }
    
    /// 配置文件放皮肤包，资源放TTComponent.
    var resourceComponent: String? {
        return self.e.skinBuilders[UIView.skinResourceComponentKey] as? String
    }
    
    var backgroundColorKey: String? {
        return self.e.skinBuilders[UIView.skinBgColorKey] as? String
    }
    
    var backgroundColor: UIColor? {
        guard let textColorKey = self.backgroundColorKey else {
            return nil
        }

        if let module = self.module,
           let color = self.skinBundle.configuration(module).color(forKey: textColorKey) {
            return color
        }
        return self.skinBundle.configuration(nil).color(forKey: textColorKey)
    }
    
    var backgroundColorStyle: HTColorStyle? {
        guard let key = self.backgroundColorKey else {
            return nil
        }
        
        if let module = self.module,
           let style = self.skinBundle.configuration(module).colorStyle(forKey: key) {
            return style
        }
        return self.skinBundle.configuration(nil).colorStyle(forKey: key)
    }
    
    var textColorKey: String? {
        return self.e.skinBuilders[UIElement.skinTextColorKey] as? String
    }
    
    var textColor: UIColor? {
        guard let textColorKey = self.textColorKey else {
            return nil
        }

        if let module = self.module,
           let color = self.skinBundle.configuration(module).color(forKey: textColorKey) {
            return color
        }
        return self.skinBundle.configuration(nil).color(forKey: textColorKey)
    }
    
    var textColorStyle: HTColorStyle? {
        guard let key: String = self.textColorKey else {
            return nil
        }
        
        if let module = self.module,
           let style = self.skinBundle.configuration(module).colorStyle(forKey: key) {
            return style
        }
        
        return self.skinBundle.configuration(nil).colorStyle(forKey: key)
    }
    
    var fontKey: String? {
        return self.e.skinBuilders[UIView.skinFontColorKey] as? String
    }
    
    var font: UIFont? {
        guard let fontKey = self.fontKey else {
            return nil
        }
        
        if let module = self.module,
           let font = self.skinBundle.configuration(module).font(forKey: fontKey) {
            return font
        }
        
        return self.skinBundle.configuration(nil).font(forKey: fontKey)
    }
    
    var imageKey: String? {
        return self.e.skinBuilders[UIView.skinImageKey] as? String
    }
    
    // MARK:
    
    var skinBundle: SkinBundle {
        let skinBundle: SkinBundle
        if let component = self.component {
            skinBundle = Bundle.skinBundle(inComponent: component) ?? Bundle.skinBundle()
        } else {
            skinBundle = Bundle.skinBundle()
        }
        
        return skinBundle
    }

    var componentSkinBundle: SkinBundle? {
        guard let component = self.component else {
            return nil
        }
        
        return Bundle.skinBundle(inComponent: component)
    }
    
    var resourceComponentSkinBundle: SkinBundle? {
        guard let resourceComponent = self.resourceComponent else {
            return nil
        }
        
        return Bundle.skinBundle(inComponent: resourceComponent)
    }
    
    
    var mainSkinBundle: SkinBundle {
        return Bundle.skinBundle()
    }
    
    var image: UIImage? {
        guard let imageKey = self.imageKey else {
            return nil
        }
        
        // 主皮肤包中 $module/appstyle 配置文件中imageKey，在resourceComponent指定组件中的图片资源
        if self.resourceComponent != nil,
            let imageName = self.mainSkinBundle.configuration(self.module).string(forKey: imageKey),
           let image = self.resourceComponentSkinBundle?.imageNamed(imageName) {
            return image
        }
        
        // 主皮肤包中，module配置文件中imageKey，在皮肤包中的图片资源
        // 或Component资源包，但一般配置了Component，就不配置module了，Component中默认style.json
        if let module = self.module,
           let image = self.skinBundle.configuration(module).image(forKey: imageKey) {
            return image
        }
        
        // 主皮肤包默认配置中的imageKey，在皮肤包中的图片资源 或
        // Component资源包中style.json配置中的imageKey，在资源包中的图片资源
        if let image = self.skinBundle.configuration(nil).image(forKey: imageKey) {
            return image
        }
        
        return nil
    }
}

// MARK: - Styler: UIView

public extension Styler where UIElement: UIView {
    @discardableResult
    func backgroundColorKey(_ key: String) -> Styler<UIElement> {
        self.e.skinBuilders[UIView.skinBgColorKey] = key
        
        StylerApplying.shared.update(element: self.e, key: UIView.skinBgColorKey) { element in
            if let color = self.backgroundColor {
                self.e.backgroundColor = color
            }
            
            #if DEBUG
            if let colorStyle = self.backgroundColorStyle {
                assert(colorStyle.color != nil, "UIView.style.backgroundColorKey gradient not supported")
                self.e.backgroundColor = colorStyle.color
            }
            #endif
        }
        
        return self
    }
    
    @discardableResult
    /// 指定使用的配置文件
    /// - Parameter module: 配置文件名称
    /// - Returns: 配置方法
    func module(_ module: String) -> Styler<UIElement> {
        self.e.skinBuilders[UIView.skinModuleKey] = module
        return self
    }
    
    @discardableResult
    /// 指定所在的业务组件
    /// - Warning: 暂不对外提供
    /// - Warning: 混淆组件名称变更
    /// - Parameter component: 组件名称
    /// - Warning: 未测试
    /// - Returns: 配置方法
    private func component(_ component: String) -> Styler<UIElement> {
        self.e.skinBuilders[UIView.skinComponentKey] = component
        return self
    }
    
    private func resourceComponent(_ resourceComponent: String) -> Styler<UIElement> {
        self.e.skinBuilders[UIView.skinResourceComponentKey] = resourceComponent
        return self
    }
}

// MARK: - Styler: UILabel

public extension Styler where UIElement: UILabel {
    @discardableResult
    func textColorKey(_ key: String) -> Styler<UIElement> {
        self.e.skinBuilders[UIView.skinTextColorKey] = key
        
        StylerApplying.shared.update(element: self.e, key: key) { element in
            if let textColor = self.textColor {
                self.e.textColor = textColor
            }
        }
        
        return self
    }
    
    @discardableResult
    func fontKey(_ key: String) -> Styler<UIElement> {
        self.e.skinBuilders[UIView.skinFontColorKey] = key
        
        StylerApplying.shared.update(element: self.e, key: key) { element in
            if let font = self.font {
                self.e.font = font
            }
        }
        
        return self
    }
}

// MARK: - Styler: GradientButton

public extension Styler where UIElement: GradientButton {
    @discardableResult
    func backgroundColorKey(_ key: String) -> Styler<UIElement> {
        self.e.skinBuilders[UIView.skinBgColorKey] = key
        
        StylerApplying.shared.update(element: self.e, key: key) { element in
            if let colorStyle = self.backgroundColorStyle {
                self.e.setBackgroundColorStyle(colorStyle)
            }
        }
        
        return self
    }
    
    @discardableResult
    func textColorKey(_ key: String) -> Styler<UIElement> {
        self.e.skinBuilders[UIView.skinTextColorKey] = key
        
        StylerApplying.shared.update(element: self.e, key: key) { element in
            if let textColor = self.textColorStyle {
                self.e.setTitleColorStyle(textColor)
            }
        }
        
        return self
    }
    
    @discardableResult
    func fontKey(_ key: String) -> Styler<UIElement> {
        self.e.skinBuilders[UIView.skinFontColorKey] = key
        
        StylerApplying.shared.update(element: self.e, key: key) { element in
            if let font = self.font {
                self.e.textLabel.font = font
            }
        }
        
        return self
    }
}

// MARK: - Styler: GradientTextLabel

public extension Styler where UIElement: GradientTextLabel {
    @discardableResult
    func textColorKey(_ key: String) -> Styler<UIElement> {
        self.e.skinBuilders[UIView.skinTextColorKey] = key
        
        StylerApplying.shared.update(element: self.e, key: key) { element in
            if let textColor = self.textColorStyle {
                self.e.textColor = textColor
            }
        }
        
        return self
    }
    
    @discardableResult
    func fontKey(_ key: String) -> Styler<UIElement> {
        self.e.skinBuilders[UIView.skinFontColorKey] = key
        
        StylerApplying.shared.update(element: self.e, key: key) { element in
            if let font = self.font {
                self.e.font = font
            }
        }
        
        return self
    }
}

public extension Styler where UIElement: UIImageView {
    @discardableResult
    func imageKey(_ key: String, resourceInComponent resourceComponent: String? = nil) -> Styler<UIElement> {
        self.e.skinBuilders[UIView.skinImageKey] = key
        self.e.skinBuilders[UIView.skinResourceComponentKey] = resourceComponent
        
        StylerApplying.shared.update(element: self.e, key: key) { element in
            if let image = self.image {
                self.e.image = image
            }
        }
        
        return self
    }
    
    @discardableResult
    func imageTransform(_ transform: @escaping ((UIImage?) -> UIImage?)) -> Styler<UIElement
    > {
        // TODO: 关联操作 待确认
        guard let key: String = self.e.skinBuilders[UIView.skinImageKey] as? String else {
            return self
        }
        
        StylerApplying.shared.update(element: self.e, key: key) { element in
            if let image = self.image {
                self.e.image = transform(image)
            }
        }
        return self
    }
}

// TODO:
//extension UIColor: SkinStyleCompatible {
//}
