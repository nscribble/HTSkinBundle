//
//  NSBundle+SkinBundle.m
//  HTSkinBundle
//
//  Created by Jason on 2022/9/30.
//

#import "NSBundle+SkinBundle.h"
#import "SkinBundleManger.h"

@implementation NSBundle (SkinBundle)

static SkinBundle *skBundle;

static NSBundle *appSkinBundle;
static NSBundle *sandboxSkinBundle;

+ (SkinBundle *)skinBundle {
    if (!skBundle) {
        [[SkinBundleManger shared] setupSkinBundle];
    }
#if DEBUG
    NSAssert(skBundle != nil, @"⚠️请先通过`SkinBundleManger`进行配置");
#endif
    return skBundle;
}

+ (SkinBundle *)skinBundleInComponent:(NSString *)component {
    return [[SkinBundleManger shared] skinBundleInComponent:component];
}

+ (HTAppStyle *)activeAppStyle {
    return [[SkinBundleManger shared] appStyle];
}

+ (void)updateSandboxSkinBundle:(NSBundle *)nsBundle {
    sandboxSkinBundle = nsBundle;
}

+ (NSBundle *)skinNSBundle {
    return [skBundle nsBundle];
}

+ (NSBundle *)appSkinBundle {
    if (appSkinBundle) {
        return appSkinBundle;
    }
    // App皮肤包
    NSURL *bundleURL = [[NSBundle mainBundle] URLForResource:@"Skin" withExtension:@"bundle"];
    if (bundleURL) {
        appSkinBundle = [NSBundle bundleWithURL:bundleURL];
    } else {// unlikely
        NSString *bundlePath = [[[[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"Frameworks"] stringByAppendingPathComponent:@"HTSkinBundle.framework"] stringByAppendingPathComponent:@"Skin.bundle"];
        appSkinBundle = [NSBundle bundleWithPath:bundlePath];
    }
    
    return appSkinBundle;
}

+ (NSBundle *)sandboxSkinBundle {
    if (sandboxSkinBundle) {
        return sandboxSkinBundle;
    }
    
    return nil;
}

@end

@implementation NSBundle (SkinPrivate)

/// ⚠️头文件在NSBundle+SkinPrivate
/// @param skinBundle 皮肤包
+ (void)updateSkinBundle:(SkinBundle *)skinBundle {
    skBundle = skinBundle;
}

+ (NSURL *)skinBundleURLInApp {
    NSURL *bundleURL = [[NSBundle mainBundle] URLForResource:@"Skin" withExtension:@"bundle"];
    if (!bundleURL) {// unlikely
        NSString *bundlePath = [[[[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"Frameworks"] stringByAppendingPathComponent:@"HTSkinBundle.framework"] stringByAppendingPathComponent:@"Skin.bundle"];
        bundleURL = [NSURL fileURLWithPath:bundlePath];
    }
    
    return bundleURL;
}

+ (NSURL *)skinBundleURLInSandbox:(NSString *)skinName {
    NSString *documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    NSURL *documentURL = [NSURL fileURLWithPath:documentPath];
    NSURL *skinBundleURL = [[documentURL URLByAppendingPathComponent:@"Skins"]
                            URLByAppendingPathComponent:skinName];
    if (![skinName hasSuffix:@"bundle"]) {
        skinBundleURL = [skinBundleURL URLByAppendingPathExtension:@"bundle"];
    }
    
    return skinBundleURL;
}

@end
