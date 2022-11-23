//
//  SkinConfigurationParser.h
//  HTSkinBundle
//
//  Created by Jason on 2022/10/9.
//

#import <Foundation/Foundation.h>
#import "SkinConfigurationProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@class SkinBundle;

/// 字体支持格式：
/// 1. 数值：titleFont: 14
/// 2. 字典：titleFont: { "fontName": "PingFangSC", "fontSize": 14}
/// 3. 字符串拼接：titleFont: "PingFangSC-Medium,14"
@interface SkinConfigurationParser : NSObject<SkinConfigurationProtocol>

+ (instancetype _Nullable)parserForPath:(NSString *)path
                           inSkinBundle:(SkinBundle *)skinBundle;

- (NSArray<NSString *> *)updatedKeysFromConfiguration:(SkinConfigurationParser *)previous;

@end

NS_ASSUME_NONNULL_END
