//
//  UIImage+SkinBundle.h
//  HTSkinBundle
//
//  Created by Jason on 2022/9/30.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class HTColorStyle;

@interface UIImage (SkinComponent)

/// 获取主皮肤包中指定业务key对应的图片
/// @param key 业务key
+ (instancetype _Nullable)skinImageWithKey:(NSString *)key;

/// 获取主皮肤包中的图片资源
/// @param name 资源名称
+ (instancetype _Nullable)skinImageNamed:(NSString *)name;

/// 获取指定资源包中的图片资源
/// @param name 资源名称
/// @param resourceBundle 资源包
+ (instancetype _Nullable)skinImageNamed:(NSString *)name
                                inBundle:(NSBundle *)resourceBundle;

// MARK: - 便捷方法

+ (instancetype _Nullable)imageWithColorStyle:(HTColorStyle *)colorStyle
                                         size:(CGSize)size;

- (UIImage *)imageWithAlpha:(CGFloat)alpha;

@end

NS_ASSUME_NONNULL_END
