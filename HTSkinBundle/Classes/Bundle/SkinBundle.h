//
//  SkinBundle.h
//  HTSkinBundle
//
//  Created by Jason on 2022/10/8.
//

#import <Foundation/Foundation.h>
#import "SkinConfigurationProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface SkinBundle : NSObject

/// 皮肤包
/// @note available after `-loadBundle`
@property (nonatomic, strong, readonly) NSBundle *nsBundle;

@property (nonatomic, strong, readonly) NSString *bundleName;
@property (nonatomic, strong, readonly) NSString *bundlePath;
@property (nonatomic, strong, readonly, nullable) NSString *zipPath;

+ (instancetype)skinBundleWithName:(NSString *)bundleName
                         bundleURL:(NSURL *)bundleURL;

/// 载入皮肤包
/// @note 全局配置文件读取、字体加载等
- (void)loadBundle;

/// 重新载入皮肤包
/// @note 配置、资源更新，资源包路径保持不改变
- (void)reloadBundle;

/// 切换到其他资源包（资源包路径改变）
/// @param updatedSkinBundle 更新后的资源包
- (void)invalidBySwitchToSkinBundle:(SkinBundle *)updatedSkinBundle;

/// 全局配置
/// @note available after `-loadBundle`
- (id<SkinConfigurationProtocol>)appConfiguration;

/// 模块的配置
/// @note 若无模块配置，则返回全局配置
/// @note available after `-loadBundle`
/// @param moduleOrNil 模块名称（json配置文件名称）
- (id<SkinConfigurationProtocol>)configuration:(NSString * _Nullable)moduleOrNil;


- (UIImage *)imageNamed:(NSString *)imageName;

@end

NS_ASSUME_NONNULL_END
