//
//  GradientTextLabel.h
//  HTSkinBundle_Example
//
//  Created by Jason on 2022/10/8.
//  Copyright © 2022 czx. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HTColorStyle.h"
//#import <HTSkinBundle/HTColorStyle.h>

NS_ASSUME_NONNULL_BEGIN

@interface GradientTextLabel : UIView

/// 文案
@property (nonatomic, copy, nullable)   NSString           *text;
/// 字体，默认14号系统字体
@property (nonatomic, strong, null_resettable) UIFont      *font;
/// 配置颜色样式
/// @note 必须配置项
@property (nonatomic, strong) HTColorStyle *textColor;
/// 文本对齐方式，默认为居中
@property (nonatomic, assign) NSTextAlignment textAlignment;

/// 以下为多行文本配置
/// 行数限制，默认为1
@property (nonatomic, assign) NSInteger numberOfLines;
/// 断行方式，默认为NSLineBreakByTruncatingTail
@property (nonatomic, assign) NSLineBreakMode lineBreakMode;
/// 富文本（一般多行），若配置textColor.gradientColor，颜色以textColor为准
@property (nonatomic, strong) NSAttributedString *attributedText;

@end

NS_ASSUME_NONNULL_END
