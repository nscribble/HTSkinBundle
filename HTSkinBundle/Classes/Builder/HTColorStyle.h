//
//  HTColorStyle.h
//  HTSkinBundle
//
//  Created by Jason on 2022/9/29.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIColor.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, GradientStyle) {
    GradientStyleLeftToRight            = 0,
    GradientStyleTopToBottom            = 1,
    GradientStyleTopLeftToBottomRight   = 2,
    GradientStyleBottomLeftToTopRight   = 3,
};

@interface HTGradientColor : NSObject

@property (nonatomic, strong) NSArray<UIColor *> *colors;
@property (nonatomic, strong) NSArray<NSValue *> *startEndPoint;// @[{0, 0.5}, {1, 0.5}]
@property (nonatomic, strong) NSArray<NSNumber *> *locations;// @[0, 0.8, 1]

+ (instancetype)colorWithColors:(NSArray<UIColor *> *)colors
                      locations:(NSArray<NSNumber *> *)locations
                          style:(GradientStyle)style;

+ (instancetype)colorWithColors:(NSArray<UIColor *> *)colors
                      locations:(NSArray<NSNumber *> *)locations
                     startPoint:(CGPoint)startPoint
                       endPoint:(CGPoint)endPoint;



@end

// rename
@interface HTColorStyle : NSObject

@property (nonatomic, strong, nullable) UIColor *color;
@property (nonatomic, strong, nullable) HTGradientColor *gradientColor;

+ (instancetype)colorStyleWith:(UIColor *)color;

+ (instancetype)colorStyleWithGradientColor:(HTGradientColor *)gradientColor;

@end

NS_ASSUME_NONNULL_END
