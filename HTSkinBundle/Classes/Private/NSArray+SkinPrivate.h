//
//  NSArray+SkinPrivate.h
//  HTSkinBundle
//
//  Created by Jason on 2022/10/8.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSArray<__covariant ObjectType> (SkinPrivate)

- (NSArray *)sk_map:(id _Nonnull (^)(ObjectType _Nonnull obj, NSUInteger idx))block;

- (NSArray *)sk_filter:(BOOL (^)(ObjectType _Nonnull, NSUInteger))block;

@end

NS_ASSUME_NONNULL_END
