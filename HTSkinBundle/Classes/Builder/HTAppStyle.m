//
//  HTAppStyle.m
//  HTSkinBundle
//
//  Created by Jason on 2022/9/29.
//
//  第一期，支持麦可App个性化定制需求（马甲包工具打包不同皮肤配置文件）。
//  支持通用元素配置和业务元素配置

#import "HTAppStyle.h"
#import <UIKit/UIColor.h>
#import <UIKit/UIFont.h>
#import <UIKit/UIImage.h>

@interface HTAppStyle ()

@property (nonatomic, strong) id<SkinConfigurationProtocol> configuration;

@property (nonatomic, strong) UIColor *primaryColor;
@property (nonatomic, strong) NSString *primaryFontName;
@property (nonatomic, strong) UIColor *badgeColor;

@end

@implementation HTAppStyle

- (instancetype)initWithConfiguration:(id<SkinConfigurationProtocol>)configuration {
    if (self = [super init]) {
        _configuration = configuration;
        
        [self parse];
    }
    
    return self;
}

/// 常用属性解析
- (void)parse {
    self.primaryColor = [self.configuration colorForKey:@"primaryColor"];
    self.primaryFontName = [self.configuration stringForKey:@"primaryFont"];
    self.badgeColor = [self.configuration colorForKey:@"badgeColor"];
}

- (UIColor *)navigationColor {
    return [self.configuration colorForKey:@"navigationColor"];
}

- (UIFont *)navigationTitleFont {
    return [self.configuration fontForKey:@"navigationTitleFont"];
}

- (UIColor *)navigationTitleColor {
    return [self.configuration colorForKey:@"navigationTitleColor"];
}

- (UIImage *)navigationBgImage {
    return [self.configuration imageForKey:@"navigationBgImage"];
}

- (UIImage *)navigationBackImage {
    return [self.configuration imageForKey:@"navigationBackImage"];
}

@end
