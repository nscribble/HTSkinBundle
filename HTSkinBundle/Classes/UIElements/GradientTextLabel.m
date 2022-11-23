//
//  GradientTextLabel.m
//  HTSkinBundle_Example
//
//  Created by Jason on 2022/10/8.
//  Copyright © 2022 czx. All rights reserved.
//

#import "GradientTextLabel.h"
#import "NSArray+SkinPrivate.h"
//#import <HTSkinBundle/NSArray+SkinPrivate.h>


@interface GradientTextLabel ()

@property (nonatomic, strong) UILabel *contentLabel;
//@property (nonatomic, strong) HTColorStyle *textColor;
@property (nonatomic, strong) CAGradientLayer *gradientLayer;

@end

@implementation GradientTextLabel

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    
    return self;
}

- (void)setup {
    self.userInteractionEnabled = NO;
    
    self.gradientLayer.frame = self.layer.bounds;
    [self.layer addSublayer:self.gradientLayer];
    
    [self addSubview:self.contentLabel];
    [self.contentLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.contentLabel.topAnchor constraintEqualToAnchor:self.topAnchor].active = YES;
    [self.contentLabel.bottomAnchor constraintEqualToAnchor:self.bottomAnchor].active = YES;
    [self.contentLabel.leadingAnchor constraintEqualToAnchor:self.leadingAnchor].active = YES;
    [self.contentLabel.trailingAnchor constraintEqualToAnchor:self.trailingAnchor].active = YES;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.gradientLayer.frame = self.layer.bounds;
    self.contentLabel.frame = self.bounds;
}

- (CGSize)intrinsicContentSize {
    return self.contentLabel.intrinsicContentSize;
}

// MARK: -

- (void)setTextColor:(HTColorStyle *)textColor {
    if (_textColor == textColor) {
        return;
    }
    _textColor = textColor;
    
    HTGradientColor *gradientColor = textColor.gradientColor;
    if (!gradientColor) {
        UIColor *color = textColor.color;
        self.contentLabel.textColor = color;
        if (self.gradientLayer.mask == self.contentLabel.layer ||
            self.layer.mask == self.contentLabel.layer) {
            self.gradientLayer.mask = nil;
            [_gradientLayer removeFromSuperlayer];
        }
        
        if (!self.contentLabel.superview) {
            [self addSubview:self.contentLabel];
            [self.contentLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
            [self.contentLabel.topAnchor constraintEqualToAnchor:self.topAnchor].active = YES;
            [self.contentLabel.bottomAnchor constraintEqualToAnchor:self.bottomAnchor].active = YES;
            [self.contentLabel.leadingAnchor constraintEqualToAnchor:self.leadingAnchor].active = YES;
            [self.contentLabel.trailingAnchor constraintEqualToAnchor:self.trailingAnchor].active = YES;
        }
        
        return;
    }
    
    [self update];
}

- (void)withoutAnimation:(void(^)(void))block {
    [CATransaction begin];
    
    !block ?: block();
    
    [CATransaction setAnimationDuration:0.0];
    [CATransaction commit];
}

- (void)update {
    if (!self.textColor) {
        return;
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.contentLabel sizeToFit];
        [self invalidateIntrinsicContentSize];
        
        HTGradientColor *gradientColor = self.textColor.gradientColor;
        if (!gradientColor) {
            return;
        }
        
        if (self.contentLabel.superview) {
            [self.contentLabel removeFromSuperview];
        }
        
        [self.layer addSublayer:self.gradientLayer];
        self.gradientLayer.frame = self.layer.bounds;
        self.gradientLayer.mask = self.contentLabel.layer;
        
        NSArray<UIColor *> *colors = gradientColor.colors;
        NSArray<NSValue *> *startEndPoint = gradientColor.startEndPoint;
        NSArray<NSNumber *> *locations = gradientColor.locations;
        NSAssert(colors.count >= 2 && colors.count == locations.count, @"❌colors.count != locations.count");
        NSAssert(startEndPoint.count == 2, @"❌startEndPoint.count != 2");
        NSAssert(locations.firstObject.floatValue >= 0 && locations.lastObject.floatValue <= 1, @"❌locations invalid");
        
        [self withoutAnimation:^{
            self.gradientLayer.colors = [colors sk_map:^id _Nonnull(UIColor * _Nonnull obj, NSUInteger idx) {
                return (__bridge id)obj.CGColor;
            }];
            self.gradientLayer.startPoint = startEndPoint.firstObject.CGPointValue;
            self.gradientLayer.endPoint = startEndPoint.lastObject.CGPointValue;
            self.gradientLayer.locations = locations;
        }];
    });
}

// MARK: -

- (CAGradientLayer *)gradientLayer {
    if (!_gradientLayer) {
        _gradientLayer = [[CAGradientLayer alloc] init];
    }
    
    return _gradientLayer;
}

- (UILabel *)contentLabel {
    if (!_contentLabel) {
        _contentLabel = [[UILabel alloc] init];
        _contentLabel.textColor = [UIColor blackColor];
        _contentLabel.backgroundColor = [UIColor clearColor];
        _contentLabel.numberOfLines = 1;
        _contentLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _contentLabel.textAlignment = NSTextAlignmentCenter;
    }
    
    return _contentLabel;
}

// MARK: - Text Label Attributes

- (void)setText:(NSString *)text {
    _text = text;
    self.contentLabel.text = text;
    [self update];
}


- (void)setFont:(UIFont *)font {
    _font = font;
    self.contentLabel.font = font;
    [self update];
}

/// 对齐方式，默认NSTextAlignmentCenter
- (void)setTextAlignment:(NSTextAlignment)textAlignment {
    _textAlignment = textAlignment;
    self.contentLabel.textAlignment = textAlignment;
    
    [self update];
}

/// 行数限制，默认1
- (void)setNumberOfLines:(NSInteger)numberOfLines {
    _numberOfLines = numberOfLines;
    self.contentLabel.numberOfLines = numberOfLines;
    
    [self update];
}

/// 若配置textColor.gradientColor，颜色以textColor为准
- (void)setAttributedText:(NSAttributedString *)attributedText {
    _attributedText = attributedText;
    self.contentLabel.attributedText = attributedText;
    
    [self update];
}

- (void)setLineBreakMode:(NSLineBreakMode)lineBreakMode {
    _lineBreakMode = lineBreakMode;
    self.contentLabel.lineBreakMode = lineBreakMode;
    
    [self update];
}

#if DEBUG
- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    NSAssert(self.textColor != nil, @"❌self.textColor == nil");
}
#endif

/* {

/// 最大宽度
- (void)setPreferredMaxLayoutWidth:(CGFloat)preferredMaxLayoutWidth {
    _preferredMaxLayoutWidth = preferredMaxLayoutWidth;
    self.contentLabel.preferredMaxLayoutWidth = preferredMaxLayoutWidth;
}}*/

@end
