//
//  HTUIStyleBuilder.h
//  HTSkinBundle
//
//  Created by Jason on 2022/10/9.
//

#import <Foundation/Foundation.h>
#import "HTColorStyle.h"
#import "GradientButton.h"
#import "GradientTextLabel.h"

NS_ASSUME_NONNULL_BEGIN

@class HTUIStyleBuilder;
@protocol HTUIStyleElement <NSObject>

- (void)style:(void(^)(HTUIStyleBuilder *styler))block;

@end

@interface HTUIStyleBuilder : NSObject

@property (nonatomic, strong, readonly) HTUIStyleBuilder *(^module)(NSString *moduleName);
@property (nonatomic, strong, readonly) HTUIStyleBuilder *(^backgroundColorWithKey)(NSString *colorKey);
@property (nonatomic, strong, readonly) HTUIStyleBuilder *(^textColorWithKey)(NSString *colorKey);
@property (nonatomic, strong, readonly) HTUIStyleBuilder *(^fontSize)(CGFloat fontSize);

// 其他可配置属性？

@end

@interface GradientButton (HTUIStyleElement)<HTUIStyleElement>

@end

@interface GradientTextLabel (HTUIStyleElement)<HTUIStyleElement>

@end

NS_ASSUME_NONNULL_END
