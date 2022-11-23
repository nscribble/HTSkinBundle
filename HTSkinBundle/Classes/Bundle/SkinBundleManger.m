//
//  SkinBundleManger.m
//  HTSkinBundle
//
//  Created by Jason on 2022/9/30.
//

#import "SkinBundleManger.h"
#import "SkinBundle.h"
#import "NSBundle+SkinBundle.h"
#import "NSBundle+SkinPrivate.h"
#import "HTAppStyle.h"

// MARK: - SkinBundleManager

@interface SkinBundleManger ()

@property (nonatomic, strong) NSString *version;

/// 主皮肤包（随App集成及动态更新的皮肤包）
@property (nonatomic, strong) SkinBundle *mainSkinBundle;
/// 业务模块的资源包（预留接口
@property (nonatomic, strong) NSMutableDictionary<NSString *, SkinBundle *> *moduleBundles;

@property (nonatomic, strong) HTAppStyle *appStyle;

@end

@implementation SkinBundleManger

+ (instancetype)shared {
    static SkinBundleManger *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [self new];
    });
    
    return manager;
}

- (void)setupSkinBundle {
    /// 加载沙盒或应用包的皮肤包
    NSString *sandboxSkinName = [[NSUserDefaults standardUserDefaults] stringForKey:@"com.skin.sandbox"];
    if (sandboxSkinName.length > 0) {
        [self loadCurrentSkinBundle:sandboxSkinName];
        [[NSUserDefaults standardUserDefaults] setObject:sandboxSkinName forKey:@"com.skin.sandbox"];// todo: kvs
    } else {
        [self loadAppSkinBundle];
    }
    
    // ① 检查主应用版本，版本更新后使用app随带资源包
    // ② 换肤需区分
    
    // 更新资源映射的皮肤包路径
    SkinBundle *skinBundle = self.mainSkinBundle;
    self.appStyle = [[HTAppStyle alloc] initWithConfiguration:skinBundle.appConfiguration];
    
    if (skinBundle.nsBundle) {
        [NSBundle updateSkinBundle:skinBundle];
    }
    [self hotReloadAppTheme];
}

- (void)loadAppSkinBundle {
    NSURL *bundleURL = [NSBundle skinBundleURLInApp];
    SkinBundle *skinBundle = [SkinBundle skinBundleWithName:@"Skin" bundleURL:bundleURL];
    [skinBundle loadBundle];
    self.mainSkinBundle = skinBundle;
}

/// 载入当前生效的皮肤包
/// @param sandboxSkinName 皮肤包名称，如Mijing_223
- (void)loadCurrentSkinBundle:(NSString *)sandboxSkinName {
    SkinBundle *skinBundle = [SkinBundle skinBundleWithName:sandboxSkinName
                                                  bundleURL:[NSBundle skinBundleURLInSandbox:sandboxSkinName]];
    [skinBundle loadBundle];
    
    SkinBundle *bundle = self.mainSkinBundle;
    self.mainSkinBundle = skinBundle;
    
    if (bundle) {
        [self notifySkinBundleChanged:bundle updatedTo:skinBundle];
    }
}

- (SkinBundle *)skinBundle {
    return self.mainSkinBundle;
}

/// 模块下的皮肤包（目前模块业务代码自行管理）
/// @warning ⚠️若需区分马甲包，请组件代码自行管理马甲包的资源包区分问题
/// @note 模块自行区分马甲包//>
/// @param module 模块名称
- (SkinBundle *)skinBundleInComponent:(NSString *)module {
    SkinBundle *bundle = [self.moduleBundles objectForKey:module];
    if ([bundle isKindOfClass:[SkinBundle class]]) {
        return bundle;
    }
    
    bundle = [self loadSkinBundleInComponent:module];
    if (bundle) {// lock
        [self.moduleBundles setObject:bundle forKey:module];
    }
    
    return bundle;
}

- (SkinBundle * _Nullable)loadSkinBundleInComponent:(NSString *)component {
    NSURL *appBundleURL = [[NSBundle mainBundle] bundleURL];
    NSString *componentBundleName = [component stringByAppendingPathExtension:@"bundle"];
    NSURL *componentBundleURL = [appBundleURL URLByAppendingPathComponent:componentBundleName];
    
    /*
    // 不一定存在（待确认
    NSURL *moduleSkinBundleURL = [moduleBundleURL URLByAppendingPathComponent:@"Skin.bundle"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:moduleSkinBundleURL.path]) {
        NSLog(@"⚠️skinInModule (%@) not found at (%@)，使用 %@", module, moduleSkinBundleURL, moduleBundleURL.lastPathComponent);
        moduleSkinBundleURL = moduleBundleURL;
    }*/
    
    // 使用模块的资源目录
    SkinBundle *bundle = [SkinBundle skinBundleWithName:component bundleURL:componentBundleURL];
    if (bundle) {
        [bundle loadBundle];
    }
    
    return bundle;
}

- (void)reloadSkinBundleAfterPatching {
    // TODO: patch applying
    
    BOOL isInAppBundle = NO;// 待补充逻辑：当前主皮肤包是否指向.app中的Skin.bundle资源包
    if (isInAppBundle) {
        NSString *versionedSkinBundleName = @"";
        [self loadCurrentSkinBundle:versionedSkinBundleName]; // notifySkinBundleChanged
    }
    else {
        [self notifySkinBundleReload:self.mainSkinBundle];
    }
}

// MARK: -

// @note 切换皮肤包（皮肤包路径发生变化），通知全局更新样式
// @note 后续应实现基于文件夹的差分更新
- (void)notifySkinBundleChanged:(SkinBundle *)skinBundle updatedTo:(SkinBundle *)updatedSkinBundle {
    [skinBundle invalidBySwitchToSkinBundle:updatedSkinBundle];
}

- (void)notifySkinBundleReload:(SkinBundle *)skinBundle {
    [skinBundle reloadBundle];
}

// MARK: -

- (NSMutableDictionary<NSString *,SkinBundle *> *)moduleBundles {
    if (!_moduleBundles) {
        _moduleBundles = [NSMutableDictionary dictionary];
    }
    
    return _moduleBundles;
}

// MARK: -

- (void)damon {
    // 皮肤热切换
    
}

// 监听日期变化
- (void)onDateChanged {
    
}

/// 全局主题更新
/// @note 根据全局配置文件加载
- (void)hotReloadAppTheme {
    // TODO: tabBar、navBar、badgeColor等配置，外部
    
    /*
    UIViewController *rootViewController = [[UIApplication sharedApplication].delegate.window rootViewController];
    [rootViewController.view removeFromSuperview];
    [[UIApplication sharedApplication].delegate.window setRootViewController:nil];
    [[UIApplication sharedApplication].delegate.window setRootViewController:rootViewController];
     */
}

/// 热切换，更新变更的key
/// @param keys 变更的key
- (void)hotReloadKeys:(NSArray<NSString *> *)keys {
    
}

@end
