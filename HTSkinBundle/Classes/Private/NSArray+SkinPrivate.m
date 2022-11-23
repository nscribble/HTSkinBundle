//
//  NSArray+SkinPrivate.m
//  HTSkinBundle
//
//  Created by Jason on 2022/10/8.
//

#import "NSArray+SkinPrivate.h"

@implementation NSArray (SkinPrivate)

- (NSArray *)sk_map:(id  _Nonnull (^)(id _Nonnull, NSUInteger))block {
    NSMutableArray *mapped = [NSMutableArray arrayWithCapacity:self.count];
    [self enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        id objm = block(obj, idx);
        if (objm) {
            [mapped addObject:objm];
        }
    }];
    return mapped;
}

- (NSArray *)sk_filter:(BOOL (^)(id _Nonnull, NSUInteger))block {
    NSMutableArray *filtered = [NSMutableArray arrayWithCapacity:self.count];
    [self enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (block(obj, idx) == YES) {
            [filtered addObject:obj];
        }
    }];
    return filtered;
}

@end
