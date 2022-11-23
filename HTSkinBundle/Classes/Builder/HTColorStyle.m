//
//  HTColorStyle.m
//  HTSkinBundle
//
//  Created by Jason on 2022/9/29.
//

#import "HTColorStyle.h"
#import "NSBundle+SkinBundle.h"

@implementation HTGradientColor

+ (instancetype)colorWithColors:(NSArray<UIColor *> *)colors
                      locations:(NSArray<NSNumber *> *)locations
                          style:(GradientStyle)style {
    HTGradientColor *color = [self new];
    color.colors = colors;
    color.locations = locations;
    switch (style) {
        case GradientStyleTopToBottom:
            color.startEndPoint = @[[NSValue valueWithCGPoint:CGPointMake(0.5, 0.0)],
                                    [NSValue valueWithCGPoint:CGPointMake(0.5, 1.0)]];
            break;
        case GradientStyleLeftToRight:
            color.startEndPoint = @[[NSValue valueWithCGPoint:CGPointMake(0.0, 0.5)],
                                    [NSValue valueWithCGPoint:CGPointMake(1.0, 0.5)]];
            break;
        case GradientStyleTopLeftToBottomRight:
            color.startEndPoint = @[[NSValue valueWithCGPoint:CGPointMake(0.0, 0.0)],
                                    [NSValue valueWithCGPoint:CGPointMake(1.0, 1.0)]];
            break;
        case GradientStyleBottomLeftToTopRight:
            color.startEndPoint = @[[NSValue valueWithCGPoint:CGPointMake(0.0, 1.0)],
                                    [NSValue valueWithCGPoint:CGPointMake(1.0, 0.0)]];
            break;
            
        default:
            break;
    }
    
    return color;
}

+ (instancetype)colorWithColors:(NSArray<UIColor *> *)colors
                      locations:(NSArray<NSNumber *> *)locations
                     startPoint:(CGPoint)startPoint
                       endPoint:(CGPoint)endPoint {
    HTGradientColor *color = [self new];
    color.colors = colors;
    color.locations = locations;
    color.startEndPoint = @[[NSValue valueWithCGPoint:startPoint],
                            [NSValue valueWithCGPoint:endPoint]];
    
    return color;
}

@end

@implementation HTColorStyle

+ (instancetype)colorStyleWith:(UIColor *)color {
    HTColorStyle *style = [self new];
    style.color = color;
    
    return style;
}

+ (instancetype)colorStyleWithGradientColor:(HTGradientColor *)gradientColor {
    HTColorStyle *style = [self new];
    style.gradientColor = gradientColor;
    
    return style;
}

@end
