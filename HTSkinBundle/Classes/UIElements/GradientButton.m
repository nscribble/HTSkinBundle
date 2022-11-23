//
//  GradientButton.m
//  HTSkinBundle_Example
//
//  Created by Jason on 2022/10/8.
//  Copyright © 2022 czx. All rights reserved.
//

#import "GradientButton.h"
#import "GradientTextLabel.h"
#import "UIImage+SkinBundle.h"
#import "HTColorStyle.h"

@interface GradientButton ()

@property (nonatomic, strong) HTColorStyle *colorStyle;
@property (nonatomic, strong) GradientTextLabel *textLabel;

@end

@implementation GradientButton

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.textLabel];
        
        self.textLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.textLabel.widthAnchor constraintLessThanOrEqualToAnchor:self.widthAnchor].active = YES;
        [self.textLabel.heightAnchor constraintLessThanOrEqualToAnchor:self.heightAnchor].active = YES;
        [self.textLabel.centerXAnchor constraintEqualToAnchor:self.centerXAnchor].active = YES;
        [self.textLabel.centerYAnchor constraintEqualToAnchor:self.centerYAnchor].active = YES;
    }
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self _updateBackgroundImage];
}

// MARK: -

- (GradientTextLabel *)textLabel {
    if (!_textLabel) {
        _textLabel = [[GradientTextLabel alloc] init];
    }
    
    return _textLabel;
}

- (void)setBackgroundColorStyle:(HTColorStyle *)colorStyle {
    if (_colorStyle == colorStyle) {
        return;
    }
    
    self.colorStyle = colorStyle;
    [self _updateBackgroundImage];
}

- (void)_updateBackgroundImage {
    if (!self.colorStyle) {
        return;
    }
    
    if (self.frame.size.height == 0) {
        return;
    }
    
    UIImage *image = [UIImage imageWithColorStyle:self.colorStyle size:CGSizeMake(self.frame.size.width, self.frame.size.height)];
    [self setBackgroundImage:image forState:UIControlStateNormal];
    [self setBackgroundImage:[image imageWithAlpha:0.8] forState:UIControlStateHighlighted];
}

- (void)setTitleColorStyle:(HTColorStyle *)colorStyle {
    [self.textLabel setTextColor:colorStyle];
}

@end
