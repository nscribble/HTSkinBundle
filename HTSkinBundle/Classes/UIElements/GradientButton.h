//
//  GradientButton.h
//  HTSkinBundle_Example
//
//  Created by Jason on 2022/10/8.
//  Copyright © 2022 czx. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class HTColorStyle;
@class GradientTextLabel;

@interface GradientButton : UIButton

@property (nonatomic, strong, readonly) GradientTextLabel *textLabel;

// MARK: - 

- (void)setBackgroundColorStyle:(HTColorStyle *)colorStyle;

- (void)setTitleColorStyle:(HTColorStyle *)colorStyle;

@end

NS_ASSUME_NONNULL_END
