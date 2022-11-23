//
//  SkinConfigurationProtocol.h
//  HTSkinBundle
//
//  Created by Jason on 2022/9/30.
//

#import <Foundation/Foundation.h>

@class HTColorStyle;
/// 配置
@protocol SkinConfigurationProtocol <NSObject>

- (NSBundle *)resourceBundle;

- (NSInteger)count;

- (NSString *)stringForKey:(NSString *)key;
- (NSInteger)intForKey:(NSString *)key;
- (CGFloat)floatForKey:(NSString *)key;
- (NSDictionary *)dictionaryForKey:(NSString *)key;
- (NSArray *)arrayForKey:(NSString *)key;

- (UIColor *)colorForKey:(NSString *)key;
- (UIFont *)fontForKey:(NSString *)key;
- (UIImage *)imageForKey:(NSString *)key;
- (HTColorStyle *)colorStyleForKey:(NSString *)key;

@end

NS_ASSUME_NONNULL_BEGIN

NS_ASSUME_NONNULL_END
