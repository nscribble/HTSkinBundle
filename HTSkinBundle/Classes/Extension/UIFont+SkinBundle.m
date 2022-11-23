//
//  UIFont+SkinBundle.m
//  HTSkinBundle
//
//  Created by Jason on 2022/9/30.
//

#import "UIFont+SkinBundle.h"
#import <CoreText/CTFontManager.h>
#import "HTAppStyle.h"
#import "NSBundle+SkinBundle.h"

@implementation UIFont (SkinComponent)

+ (instancetype)skinFontWithSize:(CGFloat)fontSize {
    UIFont *font = nil;
    NSString *fontName = [[NSBundle activeAppStyle] primaryFontName];
    if (fontName) {
        font = [UIFont fontWithName:fontName size:fontSize];
#if DEBUG
        NSAssert(font != nil, @"%@-%@ 字体实例化失败", fontName, @(fontSize));
#endif
    }
    
    if (!font) {
        font = [UIFont systemFontOfSize:fontSize];
    }
    
    return font;
}

/// 根据业务字体key获取对应的字体
/// @note 一般情况字体全局配置即可，业务通过fontSize动态获取字体（`+skinFontWithSize:`）
/// @param key 字体配置的业务key，如navFont。请确保字体已加载。
+ (instancetype)fontWithKey:(NSString *)key size:(CGFloat)fontSize {
    UIFont *font = [[NSBundle skinBundle].appConfiguration fontForKey:key];
    if (!font) {
        font = [UIFont skinFontWithSize:fontSize];
    }
    
    return font;
}

/// 根据业务字体key获取对应的字体
/// @param key 字体业务key
/// @param module 配置文件名
/// @param fontSize 字号
+ (instancetype)fontWithKey:(NSString *)key module:(NSString *)module size:(CGFloat)fontSize {
    UIFont *font = [[NSBundle skinBundle].appConfiguration fontForKey:key];
    if (!font) {
        font = [UIFont skinFontWithSize:fontSize];
    }
    
    return font;
}

// MARK: -

+ (BOOL)registerFontWithURL:(NSURL *)fontURL error:(NSError *__autoreleasing  _Nullable * _Nullable)outError {
#if DEBUG
    NSAssert([[NSFileManager defaultManager] fileExistsAtPath:([fontURL isFileURL] ? fontURL.path : fontURL.absoluteString)], @"⚠️字体%@路径不存在", fontURL);
#endif
    
    CFURLRef url = (__bridge CFURLRef)fontURL;
    CGDataProviderRef provider = CGDataProviderCreateWithURL(url);
    if (!provider) {
        NSURL *fileURL = [NSURL fileURLWithPath:[fontURL absoluteString]];
        provider = CGDataProviderCreateWithURL((__bridge CFURLRef)fileURL);
        if (!provider) {
            if (outError) {
                *outError = [NSError errorWithDomain:@"com.skinbundle.error"
                                                code:-1
                                            userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"无法载入字体（%@）", fontURL]}];
            }
            return NO;
        }
    }
    
    CFErrorRef error;
    CGFontRef font = CGFontCreateWithDataProvider(provider);
    if (!CTFontManagerRegisterGraphicsFont(font, &error)) {
        CFStringRef errorDescription = CFErrorCopyDescription(error);
        CFIndex code = CFErrorGetCode(error);
        CFErrorDomain domain = CFErrorGetDomain(error);
        CFDictionaryRef userInfo = CFErrorCopyUserInfo(error);
        
        if (outError) {
            *outError = [NSError errorWithDomain:(__bridge NSErrorDomain _Nonnull)(domain)
                                            code:code
                                        userInfo:(__bridge NSDictionary *)userInfo];
        }
        CFRelease(errorDescription);
    }
    
    CGFontRelease(font);
    CGDataProviderRelease(provider);
    
    return YES;
}

// MARK: - 便捷方法

+ (instancetype)pingFangSC:(CGFloat)fontSize {
    return [UIFont fontWithName:@"PingFang SC" size:fontSize] ?: [UIFont skinFontWithSize:fontSize];
}

+ (instancetype)pingFangSCRegular:(CGFloat)fontSize {
    return [UIFont fontWithName:@"PingFangSC-Regular" size:fontSize] ?: [UIFont skinFontWithSize:fontSize];
}

+ (instancetype)pingFangSCMedium:(CGFloat)fontSize {
    return [UIFont fontWithName:@"PingFangSC-Medium" size:fontSize] ?: [UIFont skinFontWithSize:fontSize];
}

+ (instancetype)pingFangSCSemibold:(CGFloat)fontSize {
    return [UIFont fontWithName:@"PingFangSC-Semibold" size:fontSize] ?: [UIFont skinFontWithSize:fontSize];
}

@end
