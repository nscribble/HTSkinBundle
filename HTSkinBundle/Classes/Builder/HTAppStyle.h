//
//  HTAppStyle.h
//  HTSkinBundle
//
//  Created by Jason on 2022/9/29.
//

#import <Foundation/Foundation.h>
#import "SkinConfigurationProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@class HTAppStyle;
@class UIColor;
@class UIImage;
@class UIFont;

@protocol HTAppStyleDelegate <NSObject>

- (void)appStyleDidUpdate:(HTAppStyle *)appStyle;

@end

@interface HTAppStyle : NSObject

/// 主色调
@property (nonatomic, strong, readonly) UIColor *primaryColor;
/// 字体名称（如）
@property (nonatomic, strong, readonly) NSString *primaryFontName;
/// 红点颜色
@property (nonatomic, strong, readonly) UIColor *badgeColor;

- (instancetype)initWithConfiguration:(id<SkinConfigurationProtocol>)configuration;

- (UIColor *)navigationColor;
- (UIFont *)navigationTitleFont;
- (UIColor *)navigationTitleColor;
- (UIImage *)navigationBgImage;
- (UIImage *)navigationBackImage;
- (UIColor *)badgeColor;

@end

NS_ASSUME_NONNULL_END
