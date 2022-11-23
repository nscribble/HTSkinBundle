//
//  UIColor+SkinBundle.h
//  HTSkinBundle
//
//  Created by Jason on 2022/9/30.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

#define HexColor(hexString) ([UIColor sk_colorWithHexString:hexString])

@interface UIColor (SkinComponent)

+ (UIColor * _Nullable)sk_colorWithHexString:(NSString * _Nonnull)string;

@end

@interface UIColor (AppStyle)

+ (UIColor *)primaryColor;

@end

NS_ASSUME_NONNULL_END
