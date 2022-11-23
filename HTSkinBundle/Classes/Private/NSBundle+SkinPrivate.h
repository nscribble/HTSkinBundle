//
//  NSBundle+SkinPrivate.h
//  HTSkinBundle
//
//  Created by Jason on 2022/10/13.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class SkinBundle;

@interface NSBundle (SkinPrivate)

/// 更新指向生效的皮肤包
+ (void)updateSkinBundle:(SkinBundle *)skinBundle;

// MARK: - internal

/// App包内的皮肤包
+ (NSURL *)skinBundleURLInApp;

/// 根据皮肤包名称查询皮肤包路径
/// @param skinName 皮肤包名称
+ (NSURL *)skinBundleURLInSandbox:(NSString *)skinName;

@end

NS_ASSUME_NONNULL_END
