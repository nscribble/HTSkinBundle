//
//  SkinConfigurationParser.m
//  HTSkinBundle
//
//  Created by Jason on 2022/10/9.
//

#import "SkinConfigurationParser.h"
#import "UIColor+SkinBundle.h"
#import "UIFont+SkinBundle.h"
#import "UIImage+SkinBundle.h"
#import "HTColorStyle.h"
#import "NSArray+SkinPrivate.h"
#import "NSBundle+SkinBundle.h"
#import "SkinBundle.h"

#define guard_non_nil_else_return(value, returnValue) \
if (!value) { \
    return returnValue; \
}

#define guard_class_else_return(value, cls, returnValue) \
if (![value isKindOfClass:cls]) {\
    return returnValue;\
}

static NSString * const SkinKeyFontSize = @"fontSize";
static NSString * const SkinKeyFontName = @"fontName";
static NSString * const SkinKeyFontWeight = @"fontWeight";// 仅系统字体
static NSString * const SkinKeyGradientColors = @"colors";
static NSString * const SkinKeyGradientLocations = @"locations";
static NSString * const SkinKeyGradientStyle = @"style";

static NSString * const SkinFontWeightLight = @"light";
static NSString * const SkinFontWeightRegular = @"regular";
static NSString * const SkinFontWeightMedium = @"medium";
static NSString * const SkinFontWeightSemibold = @"semibold";
static NSString * const SkinFontWeightBold = @"bold";

@interface SkinConfigurationParser ()

@property (nonatomic, strong) NSBundle *nsBundle;

@property (nonatomic, strong) NSString *version;
@property (nonatomic, strong) NSString *jsonPath;

@property (nonatomic, strong) NSDictionary *configurations;

@end

@implementation SkinConfigurationParser

+ (instancetype)parserForPath:(NSString *)path
                 inSkinBundle:(SkinBundle *)skinBundle {
    SkinConfigurationParser *conf = [self new];
    conf.nsBundle = skinBundle.nsBundle;
    conf.jsonPath = path;
    
    [conf parseFromJSONFile:path];
    
    return conf;
}

- (void)parseFromJSONFile:(NSString *)filePath {
    NSAssert(filePath != nil, @"⚠️Skin filePath is nil");
    if (!filePath) {
        return;
    }
    
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    if (data) {
        NSError *error = nil;
        NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingFragmentsAllowed error:&error];
        if ([jsonObject isKindOfClass:[NSDictionary class]] && !error) {
            self.configurations = jsonObject;
        }
    }
    
    if (!self.configurations) {
        NSLog(@"⚠️failed to parse configurations: %@", filePath);
    }
}

- (NSArray<NSString *> *)updatedKeysFromConfiguration:(SkinConfigurationParser *)previous {
    NSDictionary *prevConfigurations = previous.configurations;
    
    NSMutableArray<NSString *> *updatedKeys = [NSMutableArray array];
    [self.configurations enumerateKeysAndObjectsUsingBlock:^(NSString *  _Nonnull key, id  _Nonnull value, BOOL * _Nonnull stop) {
        if (!prevConfigurations[key]) {// 新增配置
            [updatedKeys addObject:key];
        } else if (![prevConfigurations[key] isEqual:value]) {// 配置更新
            [updatedKeys addObject:key];
        }
    }];
    
    return updatedKeys;
}

// MARK: -

- (NSBundle *)resourceBundle {
    return self.nsBundle;
}

- (NSInteger)count {
    return self.configurations.count;
}

// MARK: -

- (NSString *)stringForKey:(NSString *)key {
    guard_non_nil_else_return(key, nil);
    
    NSString *value = self.configurations[key];
    guard_class_else_return(value, [NSString class], nil);
    
    return value;
}

- (NSInteger)intForKey:(NSString *)key {
    guard_non_nil_else_return(key, 0);
    NSNumber *value = self.configurations[key];
    guard_class_else_return(value, [NSNumber class], 0);
    
    return [value integerValue];
}

- (CGFloat)floatForKey:(NSString *)key {
    guard_non_nil_else_return(key, 0);
    NSNumber *value = self.configurations[key];
    guard_class_else_return(value, [NSNumber class], 0);
    
    return [value integerValue];
}

- (NSDictionary *)dictionaryForKey:(NSString *)key {
    guard_non_nil_else_return(key, nil);
    NSDictionary *value = self.configurations[key];
    guard_class_else_return(value, [NSDictionary class], nil);
    
    return value;
}

- (NSArray *)arrayForKey:(NSString *)key {
    guard_non_nil_else_return(key, nil);
    NSArray *value = self.configurations[key];
    guard_class_else_return(value, [NSArray class], nil);
    
    return value;
}

- (UIColor *)colorForKey:(NSString *)key {
    guard_non_nil_else_return(key, nil);
    
    NSString *colorHex = [self stringForKey:key];
    if (!colorHex) {
        return nil;
    }
    
    NSString *mappingKey = [colorHex stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"0Xx#0123456789ABCEDFabcdef"]];
    mappingKey = [mappingKey stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (mappingKey.length > 0) {
        NSAssert(![key isEqual:mappingKey], @"⚠️colorForKey(%@) 配置不合法", key);
        id<SkinConfigurationProtocol> commonConfiguration = [[NSBundle skinBundle] appConfiguration];
        UIColor *color = [commonConfiguration colorForKey:mappingKey] ?: [self colorForKey:mappingKey];
        NSAssert(color != nil, @"⚠️colorForKey(%@) 配置找不到 %@ 的color", key, mappingKey);
        return color;
    }
    
    return [UIColor sk_colorWithHexString:colorHex];
}

- (UIFont *)fontForKey:(NSString *)key {
    guard_non_nil_else_return(key, nil);
    
    CGFloat fontSize = [self floatForKey:key];
    if (fontSize > 0) {
        return [UIFont skinFontWithSize:fontSize];
    }
    
    NSDictionary *fontInfo = [self dictionaryForKey:key];
    if (fontInfo) {
        NSString *fontName = fontInfo[SkinKeyFontName];
        CGFloat fontSize = [fontInfo[SkinKeyFontSize] floatValue];
        NSAssert(fontSize > 0, @"⚠️fontSize未配置（%@）", key);
        fontSize = fontSize > 0 ? fontSize : [UIFont systemFontSize];
        if (fontName) {
            return [UIFont fontWithName:fontName size:fontSize];
        }
        
        if (fontInfo[SkinKeyFontWeight]) {
            UIFontWeight fontWeight = [self fontWeightFromKey:fontInfo[SkinKeyFontWeight]];
            return [UIFont systemFontOfSize:fontSize weight:fontWeight];
        }
        
        return [UIFont skinFontWithSize:fontSize];
    }
    
    NSString *mixedNameSize = [self stringForKey:key];
    if (mixedNameSize.length) {
#if DEBUG
        NSString *trimmed = [mixedNameSize stringByTrimmingCharactersInSet:[NSCharacterSet decimalDigitCharacterSet]];
        NSAssert(trimmed.length > 0, @"⚠️fontSize配置请使用数值（%@）",key);
#endif
        NSArray<NSString *> *nameSize = [mixedNameSize componentsSeparatedByString:@","];
        NSAssert(nameSize.count == 2, @"⚠️字体配置格式异常（%@）: （%@）", key, mixedNameSize);
        NSString *fontName = [nameSize.firstObject stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        NSString *fontSizeStr = [nameSize.lastObject stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        
        return [UIFont fontWithName:fontName size:fontSizeStr.floatValue];
    }
    
    NSAssert(NO, @"⚠️字体未配置（%@）",key);
    
    return nil;
}

- (UIImage *)imageForKey:(NSString *)key {
    guard_non_nil_else_return(key, nil);
    
    NSString *imageName = [self stringForKey:key];
    //NSAssert(imageName != nil, @"⚠️imageForKey（%@）, string nil", key);
    if (!imageName) {
        return nil;
    }
    
    return [UIImage skinImageNamed:imageName inBundle:self.nsBundle];
}

- (HTColorStyle *)colorStyleForKey:(NSString *)key {
    guard_non_nil_else_return(key, nil);
    
    NSString *colorHex = [self stringForKey:key];
    if ([colorHex isKindOfClass:[NSString class]]) {// 二次映射的颜色配置key
        NSString *mappingKey = [colorHex stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"0Xx#123456789ABCEDFabcdef"]];
        mappingKey = [mappingKey stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if (mappingKey.length > 0) {
            NSAssert(![key isEqual:mappingKey], @"⚠️colorStyleForKey(%@) 配置不合法", key);
            id<SkinConfigurationProtocol> commonConfiguration = [[NSBundle skinBundle] appConfiguration];
            HTColorStyle *colorStyle = [commonConfiguration colorStyleForKey:mappingKey] ?: [self colorStyleForKey:mappingKey];
            return colorStyle;
        }
        
        UIColor *color = [UIColor sk_colorWithHexString:colorHex];
        return [HTColorStyle colorStyleWith:color];
    }
    
    NSDictionary *gradientInfos = [self dictionaryForKey:key];
    if ([gradientInfos isKindOfClass:[NSDictionary class]]) {
        NSArray<NSString *> *colorHexs = gradientInfos[SkinKeyGradientColors];
        NSArray<NSNumber *
        > *locations = gradientInfos[SkinKeyGradientLocations];
        NSNumber *type = gradientInfos[SkinKeyGradientStyle];
        
        NSArray<UIColor *> *colors = [colorHexs sk_map:^id _Nonnull(NSString * _Nonnull obj, NSUInteger idx) {
            if (![obj isKindOfClass:[NSString class]]) {
                return nil;
            }
            return [UIColor sk_colorWithHexString:obj];
        }];
        
        NSAssert(colors.count == locations.count, @"⚠️gradient color (%@) colors 与 locations 数目不一致", key);
        if (colors.count != locations.count) {
            return nil;
        }
        
        NSAssert(type.integerValue <= GradientStyleBottomLeftToTopRight, @"⚠️gradient style invalid (%@)，请参考`GradientStyle`", type);
        GradientStyle style = GradientStyleLeftToRight;
        if (type.integerValue <= GradientStyleBottomLeftToTopRight) {
            style = (GradientStyle)type.integerValue;
        }
        
        HTGradientColor *gradientColor = [HTGradientColor colorWithColors:colors locations:locations style:style];
        return [HTColorStyle colorStyleWithGradientColor:gradientColor];
    }
    
    NSArray *gradientColors = [self arrayForKey:key];
    if (gradientColors.count >= 2) {
        NSArray<NSString *> *colorHexs = gradientColors;
        NSMutableArray<NSNumber *
        > *locations = @[].mutableCopy;
        CGFloat ratio = ((NSInteger)(100 / MAX(1, colorHexs.count - 1))) / 100.0;
        for (NSInteger index = 0; index < colorHexs.count - 1; index ++) {
            [locations addObject:@(ratio * index)];
        }
        [locations addObject:@(1.0)];
        NSNumber *type = @(GradientStyleLeftToRight);
        
        NSArray<UIColor *> *colors = [colorHexs sk_map:^id _Nonnull(NSString * _Nonnull obj, NSUInteger idx) {
            if (![obj isKindOfClass:[NSString class]]) {
                return nil;
            }
            return [UIColor sk_colorWithHexString:obj];
        }];
        
        NSAssert(colors.count == locations.count, @"⚠️gradient color (%@) colors 与 locations 数目不一致", key);
        if (colors.count != locations.count) {
            return nil;
        }
        
        NSAssert(type.integerValue <= GradientStyleBottomLeftToTopRight, @"⚠️gradient style invalid (%@)，请参考`GradientStyle`", type);
        GradientStyle style = GradientStyleLeftToRight;
        if (type.integerValue <= GradientStyleBottomLeftToTopRight) {
            style = (GradientStyle)type.integerValue;
        }
        
        HTGradientColor *gradientColor = [HTGradientColor colorWithColors:colors locations:locations style:style];
        return [HTColorStyle colorStyleWithGradientColor:gradientColor];
    }
    
    if ([self.nsBundle.bundlePath.lastPathComponent isEqual:@"Skin.bundle"]) {
        NSAssert(NO, @"colorStyleForKey: %@, appstyle中无法找到配置，请添加配置或先指定module。或未支持的数据：%@，请使用#RRGGBB(AA)或{..}", key, colorHex);
    }
    
//    NSAssert(NO, @"colorStyleForKey: %@, 未支持的数据：%@，请使用#RRGGBB(AA)或{..}", key, colorHex);
    
    return nil;
}

// MARK: -

- (UIFontWeight)fontWeightFromKey:(NSString *)key {
    static NSDictionary<NSString *, NSNumber*> *mappings = nil;
    if (!mappings) {
        mappings = @{SkinFontWeightLight: @(UIFontWeightLight),
                     SkinFontWeightRegular: @(UIFontWeightRegular),
                     SkinFontWeightMedium: @(UIFontWeightMedium),
                     SkinFontWeightSemibold: @(UIFontWeightSemibold),
                     SkinFontWeightBold: @(UIFontWeightBold)};
    }
    
    NSNumber * weight = mappings[key];
    NSAssert(weight != nil, @"⚠️fontWeight不支持（%@）", key);
    if (weight) {
        return (UIFontWeight)[weight floatValue];
    }
    
    return UIFontWeightRegular;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@, %p> %@", NSStringFromClass(self.class), self, self.configurations];
}

@end
