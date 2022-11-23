//
//  UIColor+SkinBundle.m
//  HTSkinBundle
//
//  Created by Jason on 2022/9/30.
//

#import "UIColor+SkinBundle.h"
#import "NSBundle+SkinBundle.h"
#import "HTAppStyle.h"

#define COLOR_USE_ARGB 1

#if COLOR_USE_ARGB
#define COLOR_STYLE_ARGB
#else
#define COLOR_STYLE_RGBA
#endif

@implementation UIColor (SkinComponent)

/// 根据主皮肤包的配置获取key对应的颜色
/// @param key 业务颜色key
+ (instancetype)colorWithKey:(NSString *)key {
    SkinBundle *skBundle = [NSBundle skinBundle];
    NSString *hexString = [skBundle.appConfiguration stringForKey:key];
    return [self sk_colorWithHexString:hexString];
}

/// 根据主皮肤包的配置获取key对应的颜色
/// @param key 业务颜色key
/// @param module 配置文件名
+ (UIColor *)colorWithKey:(NSString *)key module:(NSString *_Nullable)module {
    SkinBundle *skBundle = [NSBundle skinBundle];
    NSString *hexString = [[skBundle configuration:module] stringForKey:key];
    return [self sk_colorWithHexString:hexString];
}

// MARK: - Hex (yy)

+ (instancetype)sk_colorWithHexString:(NSString *)hexStr {
    CGFloat r, g, b, a;
#ifdef COLOR_STYLE_ARGB
    if (sk_hexStrToARGB(hexStr, &r, &g, &b, &a)) {
        return [UIColor colorWithRed:r green:g blue:b alpha:a];
    }
#else
    if (sk_hexStrToRGBA(hexStr, &r, &g, &b, &a)) {
        return [UIColor colorWithRed:r green:g blue:b alpha:a];
    }
#endif
    return nil;
}

static inline NSUInteger sk_hexStrToInt(NSString *str) {
    uint32_t result = 0;
    sscanf([str UTF8String], "%X", &result);
    return result;
}

static BOOL sk_hexStrToRGBA(NSString *str,
                         CGFloat *r, CGFloat *g, CGFloat *b, CGFloat *a) {
    str = [[str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    if ([str hasPrefix:@"#"]) {
        str = [str substringFromIndex:1];
    } else if ([str hasPrefix:@"0X"]) {
        str = [str substringFromIndex:2];
    }
    
    NSUInteger length = [str length];
    //         RGB            RGBA          RRGGBB        RRGGBBAA
    if (length != 3 && length != 4 && length != 6 && length != 8) {
        return NO;
    }
    
    //RGB,RGBA,RRGGBB,RRGGBBAA
    if (length < 5) {
        *r = sk_hexStrToInt([str substringWithRange:NSMakeRange(0, 1)]) / 255.0f;
        *g = sk_hexStrToInt([str substringWithRange:NSMakeRange(1, 1)]) / 255.0f;
        *b = sk_hexStrToInt([str substringWithRange:NSMakeRange(2, 1)]) / 255.0f;
        if (length == 4)  *a = sk_hexStrToInt([str substringWithRange:NSMakeRange(3, 1)]) / 255.0f;
        else *a = 1;
    } else {
        *r = sk_hexStrToInt([str substringWithRange:NSMakeRange(0, 2)]) / 255.0f;
        *g = sk_hexStrToInt([str substringWithRange:NSMakeRange(2, 2)]) / 255.0f;
        *b = sk_hexStrToInt([str substringWithRange:NSMakeRange(4, 2)]) / 255.0f;
        if (length == 8) *a = sk_hexStrToInt([str substringWithRange:NSMakeRange(6, 2)]) / 255.0f;
        else *a = 1;
    }
    return YES;
}

static BOOL sk_hexStrToARGB(NSString *str,
                         CGFloat *r, CGFloat *g, CGFloat *b, CGFloat *a) {
    str = [[str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    if ([str hasPrefix:@"#"]) {
        str = [str substringFromIndex:1];
    } else if ([str hasPrefix:@"0X"]) {
        str = [str substringFromIndex:2];
    }
    
    NSUInteger length = [str length];
    //         RGB            ARGB          RRGGBB        AARRGGBB
    if (length != 3 && length != 4 && length != 6 && length != 8) {
        return NO;
    }
    
    NSInteger rgbIndexBegin = 0;
    NSInteger channelWidth = 2;
    if (length == 4 || length == 8) { // ARGB || AARRGGBB
        rgbIndexBegin = 1;
    }
    if (length < 5) {
        channelWidth = 1;
    }
    
    *r = sk_hexStrToInt([str substringWithRange:NSMakeRange((rgbIndexBegin + 0) * channelWidth, channelWidth)]) / 255.0f;
    *g = sk_hexStrToInt([str substringWithRange:NSMakeRange((rgbIndexBegin + 1) * channelWidth, channelWidth)]) / 255.0f;
    *b = sk_hexStrToInt([str substringWithRange:NSMakeRange((rgbIndexBegin + 2) * channelWidth, channelWidth)]) / 255.0f;
    
    // ARGB || AARRGGBB
    if (length == 4 || length == 8) {
        *a = sk_hexStrToInt([str substringWithRange:NSMakeRange(0, channelWidth)]) / 255.0f;
    } else {
        *a = 1;
    }
    
    return YES;
}

@end

@implementation UIColor (AppStyle)

+ (UIColor *)primaryColor {
    return [[NSBundle activeAppStyle] primaryColor];
}

@end
