//
//  UIFont+SkinBundle.h
//  HTSkinBundle
//
//  Created by Jason on 2022/9/30.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIFont (SkinComponent)


/// 获取主皮肤包字体的指定字号的字体
/// @param fontSize 字号
+ (instancetype)skinFontWithSize:(CGFloat)fontSize;

// MARK: - 部分系统自带字体

// PingFangSC-Semibold
+ (instancetype)pingFangSCSemibold:(CGFloat)fontSize;
// PingFangSC-Medium
+ (instancetype)pingFangSCMedium:(CGFloat)fontSize;
// PingFangSC-Regular
+ (instancetype)pingFangSCRegular:(CGFloat)fontSize;
// PingFang SC
+ (instancetype)pingFangSC:(CGFloat)fontSize;

// MARK: -

/// 注册字体
/// @param fontURL 字体路径
/// @param outError 错误信息
+ (BOOL)registerFontWithURL:(NSURL *)fontURL error:(NSError *__autoreleasing  _Nullable * _Nullable)outError;

@end

NS_ASSUME_NONNULL_END
