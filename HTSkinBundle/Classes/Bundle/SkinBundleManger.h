//
//  SkinBundleManger.h
//  HTSkinBundle
//
//  Created by Jason on 2022/9/30.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class SkinBundle;
@class HTAppStyle;

@interface SkinBundleManger : NSObject

/// 当前使用的皮肤包
/// @note 包含.app应用目录及沙盒目录下的皮肤包管理
/// @note `-setupSkinBundle`后可用
@property (nonatomic, strong, readonly) SkinBundle *skinBundle;

/// 应用全局风格配置
@property (nonatomic, strong, readonly) HTAppStyle *appStyle;

+ (instancetype)shared;

- (void)setupSkinBundle;

- (SkinBundle * _Nullable)skinBundleInComponent:(NSString *)component;

@end

NS_ASSUME_NONNULL_END
