//
//  HTUIStyleBuilder.m
//  HTSkinBundle
//
//  Created by Jason on 2022/10/9.
//

#import "HTUIStyleBuilder.h"
#import "UIFont+SkinBundle.h"
#import "UIColor+SkinBundle.h"
#import "UIImage+SkinBundle.h"
#import "NSBundle+SkinBundle.h"

#import "GradientTextLabel.h"

@interface HTUIStyleBuilder ()

@property (nonatomic, strong) NSString *module_;
@property (nonatomic, strong) NSString *backgroundColorKey;
@property (nonatomic, strong) NSString *textColorKey;
@property (nonatomic, strong) NSString *fontNameKey;
@property (nonatomic, assign) CGFloat fontSize_;

@property (nonatomic, strong) HTColorStyle *backgroundColor;
@property (nonatomic, strong) HTColorStyle *textColor;
@property (nonatomic, strong) UIFont *font;

@end

@implementation HTUIStyleBuilder

// MARK: -
- (HTUIStyleBuilder * _Nonnull (^)(NSString * _Nonnull))backgroundColorWithKey {
    return ^HTUIStyleBuilder *(NSString *key) {
        self.backgroundColorKey = key;
        return self;
    };
}

- (HTUIStyleBuilder * _Nonnull (^)(NSString * _Nonnull))textColorWithKey {
    return ^HTUIStyleBuilder *(NSString *key) {
        self.textColorKey = key;
        return self;
    };
}

- (HTUIStyleBuilder * _Nonnull (^)(NSString * _Nonnull))module {
    return ^HTUIStyleBuilder *(NSString *name) {
        self.module_ = name;
        return self;
    };
}

- (HTUIStyleBuilder * _Nonnull (^)(CGFloat))fontSize {
    return ^HTUIStyleBuilder *(CGFloat fontSize) {
        self.fontSize_ = fontSize;
        return self;
    };
}

@end

@implementation GradientButton (HTUIStyleElement)

- (void)style:(void (^)(HTUIStyleBuilder * _Nonnull))block {
    HTUIStyleBuilder *builder = [HTUIStyleBuilder new];
    !block ?: block(builder);
    
    [self render:builder];
}

- (void)render:(HTUIStyleBuilder *)builder {
    // get configuration from key & module
    NSString *module = builder.module_;
    NSString *backgroundColorKey = builder.backgroundColorKey;
    NSString *textColorKey = builder.textColorKey;
    
    id<SkinConfigurationProtocol> configuration = [[NSBundle skinBundle] configuration:module];
    HTColorStyle *textColor = [configuration colorStyleForKey:textColorKey];
    HTColorStyle *backgroundColor = [configuration colorStyleForKey:backgroundColorKey];
    
    if (textColor) {
        [self setTitleColorStyle:textColor];
    }
    
    if (backgroundColor) {
        [self setBackgroundColorStyle:backgroundColor];
    }
    
    if (builder.fontSize_ > 0) {
        UIFont *font = [UIFont skinFontWithSize:builder.fontSize_];
        if (font) {
            [self.textLabel setFont:font];
        }
    }
    
}

// MARK: -

@end

@implementation GradientTextLabel (HTUIStyleElement)

- (void)style:(void (^)(HTUIStyleBuilder * _Nonnull))block {
    HTUIStyleBuilder *builder = [HTUIStyleBuilder new];
    !block ?: block(builder);
    
    [self render:builder];
}

- (void)render:(HTUIStyleBuilder *)builder {
    NSString *module = builder.module_;
    NSString *backgroundColorKey = builder.backgroundColorKey;
    NSString *textColorKey = builder.textColorKey;
    
    id<SkinConfigurationProtocol> configuration = [[NSBundle skinBundle] configuration:module];
    HTColorStyle *textColor = [configuration colorStyleForKey:textColorKey];
    HTColorStyle *backgroundColor = [configuration colorStyleForKey:backgroundColorKey];
    
    if (textColor) {
        [self setTextColor:textColor];
    }
    
    if (backgroundColor.color) {
        [self setBackgroundColor:backgroundColor.color];
    }
    
    if (builder.fontSize_ > 0) {
        UIFont *font = [UIFont skinFontWithSize:builder.fontSize_];
        if (font) {
            [self setFont:font];
        }
    }
}

@end
