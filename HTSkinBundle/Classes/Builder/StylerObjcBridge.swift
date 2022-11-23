//
//  StylerObjcBridge.swift
//  HTSkinBundle
//
//  Created by Jason on 2022/10/31.
//

import Foundation

@objc
@objcMembers
public class StylerObjcBridge: NSObject {
    public class func notifyUpdate(_ skinBundle: SkinBundle, module: String, updatedKeys: [String]) {
        #if DEBUG
        if updatedKeys.count > 100 {
            print("⚠️更新配置数目较多，建议`StylerApplying.refreshAll`全局刷新")
        }
        #endif
        let component: String? = self.componentOfSkinBundle(skinBundle)
        updatedKeys.forEach { key in
            StylerApplying.shared.refresh(module: module, component: component, key: key)
        }
    }
    
    public class func notifyReload(_ skinBundle: SkinBundle) {
        StylerApplying.shared.refreshAll()
    }
    
    private class func componentOfSkinBundle(_ skinBundle: SkinBundle) -> String? {
        if skinBundle.bundleName == "Skin" {
            return StylerApplying.closureKeyComponentNameDefault
        }
        
        return skinBundle.bundleName
    }
}
