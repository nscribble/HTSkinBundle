//
//  SkinBundle.m
//  HTSkinBundle
//
//  Created by Jason on 2022/10/8.
//

#import "SkinBundle.h"
#import "SkinConfigurationParser.h"
#import "NSBundle+SkinBundle.h"
#import "UIFont+SkinBundle.h"
#import "HTAppStyle.h"
#import "NSArray+SkinPrivate.h"
#import "HTSkinBundle/HTSkinBundle-Swift.h"

static NSString * const SkinPrimaryColorKey = @"primaryColor";
static NSString * const SkinPrimaryFontKey = @"primaryFont";
static NSString * const SkinFontsKey = @"registerFonts";
static NSString * const SkinShouldSearchFontsKey = @"shouldSearchFonts";

#define SkinBundleAutoSeachFonts 1

@interface SkinBundle ()

@property (nonatomic, strong) NSString *bundleName;
@property (nonatomic, strong) NSString *bundlePath;
@property (nonatomic, strong, nullable) NSString *zipPath;

@property (nonatomic, strong) NSURL *nsBundleURL;
@property (nonatomic, strong) NSBundle *nsBundle;
/// 全局样式配置（默认只有主皮肤包提供）
/// @note available after `-loadBundle`
@property (nonatomic, strong) SkinConfigurationParser *appStyleConfiguration;
@property (nonatomic, strong) NSMutableDictionary<NSString *, SkinConfigurationParser *> *modulerSkinParsers;

@end

@implementation SkinBundle

+ (instancetype)skinBundleWithName:(NSString *)bundleName bundleURL:(NSURL *)bundleURL {
    SkinBundle *bundler = [self new];
    bundler.bundleName = bundleName;
    bundler.bundlePath = [bundleURL path];// fileURL
    
    return bundler;
}

- (void)loadBundle {
    if (self.nsBundle) {
        return;
    }
    
    NSURL *skinBundleURL = [NSURL fileURLWithPath:self.bundlePath];
    if (![skinBundleURL isFileURL]) {
        return;
    }
    
    NSBundle *bundle = [NSBundle bundleWithURL:skinBundleURL];
    self.nsBundle = bundle;
    self.nsBundleURL = skinBundleURL;
    
    [self registerFonts];
}

- (void)registerFonts {
    if (!self.nsBundle) {
        return;
    }
    
    NSString *bundlePath = [self.nsBundle bundlePath];
    // 字体加载（若有）
    NSArray<NSString *> *fontFiles = [self.appStyleConfiguration arrayForKey:SkinFontsKey];
    if (fontFiles.count <= 0 && SkinBundleAutoSeachFonts &&
        [self.appStyleConfiguration intForKey:SkinShouldSearchFontsKey] != 0) {// 搜索本地ttf字体
        NSError *error = nil;
        NSArray<NSString *> *contents =
        [[NSFileManager defaultManager] contentsOfDirectoryAtPath:bundlePath error:&error];
        if (error) {
            return;
        }
        
        fontFiles =
        [contents sk_filter:^BOOL(NSString * _Nonnull file, NSUInteger index) {
            return [file hasSuffix:@"ttf"];
        }];
    }
    
    [fontFiles enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *fontName = [obj containsString:@"."] ? obj : [obj stringByAppendingString:@".ttf"];
        if (fontName) {
            NSURL *fontURL = [[NSURL URLWithString:bundlePath] URLByAppendingPathComponent:fontName];
            NSError *error = nil;
            BOOL result = [UIFont registerFontWithURL:fontURL error:&error];
            if (!result || error) {
#if DEBUG
                NSLog(@"字体注册失败: %@", error);
#endif
            }
        }
    }];
}

- (void)reloadBundle {
    [self updateConfigurationsOnBundleUpdated];
    
    /// 保留动态加载字体的可能
    [self registerFonts];
}

- (void)invalidBySwitchToSkinBundle:(SkinBundle *)updatedSkinBundle {
    [StylerObjcBridge notifyReload:self];
}

/// 更新配置
- (void)updateConfigurationsOnBundleUpdated {
    NSString *bundlePath = [self.nsBundle bundlePath];
    NSError *error = nil;
    NSArray<NSString *> *contents =
    [[NSFileManager defaultManager] contentsOfDirectoryAtPath:bundlePath error:&error];
    if (error) {
        return;
    }
    
    NSArray<NSString *> *jsonFiles =
    [contents sk_filter:^BOOL(NSString * _Nonnull file, NSUInteger index) {
        return [file hasSuffix:@"json"];
    }];
    
    [jsonFiles enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *module = [obj hasSuffix:@".json"] ? [obj stringByReplacingOccurrencesOfString:@".json" withString:@""] : obj;
        if ([module isEqual:@"appstyle"]) {// 通常只更新主皮肤包，忽略Component等逻辑
            module = nil;
        }
        
        [self updateConfiguration:module];
    }];
}

/// 部分配置更新后，触发样式配置生效
/// @note 若资源包整包更新或大版本更新，建议进行全局刷新
/// @param module 模块，可空
- (void)updateConfiguration:(NSString * _Nullable)module {
    // 更新前的配置（及缓存）
    SkinConfigurationParser *configuration = [self configuration:module];
    if (!module) {
        self.appStyleConfiguration = nil;
    } else {
        [self.modulerSkinParsers removeObjectForKey:module];
    }
    
    // 重新生成配置
    SkinConfigurationParser *updated = [self configuration:module];
    NSArray<NSString *> *keys = [updated updatedKeysFromConfiguration:configuration];
    if (keys.count > 0) {
        [StylerObjcBridge notifyUpdate:self module:module updatedKeys:keys];
    }
}

// MARK: -

/// 全局样式配置解析
/// @note available after `-loadBundle`
- (SkinConfigurationParser *)appStyleConfiguration {
    if (!_appStyleConfiguration) {
        NSString *filePath = [[self.nsBundleURL URLByAppendingPathComponent:@"appstyle.json"] path];
        _appStyleConfiguration = [SkinConfigurationParser parserForPath:filePath inSkinBundle:self];

        if (_appStyleConfiguration.count <= 0) {// && ![self.nsBundleURL.lastPathComponent isEqual:@"Skin.bundle"]
            filePath = [[self.nsBundleURL URLByAppendingPathComponent:@"style.json"] path];
            _appStyleConfiguration = [SkinConfigurationParser parserForPath:filePath inSkinBundle:self];
        }
    }
    
    return _appStyleConfiguration;
}

- (NSMutableDictionary<NSString *,SkinConfigurationParser *> *)modulerSkinParsers {
    if (!_modulerSkinParsers) {
        _modulerSkinParsers = [NSMutableDictionary dictionary];
    }
    
    return _modulerSkinParsers;
}

- (SkinConfigurationParser *)configurationOfModule:(NSString *)module {
    if (!module) {
        return nil;
    }
    
    SkinConfigurationParser *parser = [self.modulerSkinParsers objectForKey:module];
    if (!parser) {
        NSString *path = [self.bundlePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.json", module]];
        
        parser = [SkinConfigurationParser parserForPath:path inSkinBundle:self];
        NSAssert(parser != nil, @"⚠️找不到模块配置%@", module);
        
        if (parser) {
            [self.modulerSkinParsers setObject:parser forKey:module];
        }
    }
    
    return parser;
}

- (id<SkinConfigurationProtocol>)appConfiguration {
    return self.appStyleConfiguration;
}

- (id<SkinConfigurationProtocol>)configuration:(NSString *)moduleOrNil {
    SkinBundle *skBundle = self;
    SkinConfigurationParser *parser = moduleOrNil ? [skBundle configurationOfModule:moduleOrNil] : skBundle.appStyleConfiguration;
    if (!parser && moduleOrNil.length) {
        parser = skBundle.appStyleConfiguration;
    }
    
    return parser;
}

- (UIImage *)imageNamed:(NSString *)imageName {
    return [UIImage imageNamed:imageName inBundle:self.nsBundle compatibleWithTraitCollection:nil];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p> %@", NSStringFromClass(self.class), self, self.bundlePath];
}

@end
