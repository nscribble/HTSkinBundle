//
//  NSBundle+SkinBundle.h
//  HTSkinBundle
//
//  Created by Jason on 2022/9/30.
//

#import <Foundation/Foundation.h>
#import "SkinBundle.h"

NS_ASSUME_NONNULL_BEGIN

@class HTAppStyle;

@interface NSBundle (SkinBundle)

/// 当前生效的皮肤包
/// @note 对于多个皮肤包，使用配置或`+updateSandboxSkinBundle:`指定的皮肤包
+ (SkinBundle *)skinBundle;

/// 便捷方法：当前生效皮肤包的资源包
+ (NSBundle *)skinNSBundle;

/// 获取指定业务Component的皮肤包
/// @note 业务Component，比如 MusicTabComponent 、EntertainComponent
/// @param component 业务组件名
+ (SkinBundle * _Nullable)skinBundleInComponent:(NSString *)component;

+ (HTAppStyle *)activeAppStyle;

@end

NS_ASSUME_NONNULL_END
