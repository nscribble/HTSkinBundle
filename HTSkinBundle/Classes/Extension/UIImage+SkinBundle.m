//
//  UIImage+SkinBundle.m
//  HTSkinBundle
//
//  Created by Jason on 2022/9/30.
//

#import "UIImage+SkinBundle.h"
#import "NSBundle+SkinBundle.h"
#import "HTColorStyle.h"
#import "NSArray+SkinPrivate.h"

@interface SkinImageCache : NSObject

@property (nonatomic, strong) NSCache<NSString *, UIImage *> *cache;

@end

@implementation SkinImageCache

+ (instancetype)shared {
    static SkinImageCache *cache = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cache = [[self alloc] init];
        
        [[NSNotificationCenter defaultCenter] addObserver:cache selector:@selector(didReceiveMemoryWarning) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
    });
    
    return cache;
}

- (void)didReceiveMemoryWarning {
    [self.cache removeAllObjects];
}

- (NSCache<NSString *,UIImage *> *)cache {
    if (!_cache) {
        _cache = [[NSCache alloc] init];
        _cache.countLimit = 100;
    }
    
    return _cache;
}

- (UIImage *)imageForKey:(NSString *)key {
    return [self.cache objectForKey:key];
}

- (void)setImage:(UIImage *)image forKey:(NSString *)key {
    [self.cache setObject:image forKey:key];
}

@end

@implementation UIImage (SkinComponent)

+ (instancetype)skinImageWithKey:(NSString *)key {
    UIImage *cache = [[SkinImageCache shared] imageForKey:key];
    if (cache) {
        return cache;
    }
    
    UIImage *image = [[NSBundle skinBundle].appConfiguration imageForKey:key];
    if (!image) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [[SkinImageCache shared] setImage:image forKey:key];
        });
    }
    
    return image;
}

+ (instancetype)skinImageNamed:(NSString *)name {
    UIImage *image = [UIImage imageNamed:name inBundle:[NSBundle skinNSBundle] compatibleWithTraitCollection:nil];
#if DEBUG
    NSAssert(image != nil, @"⚠️skinImageNamed(%@) is nil", name);
#endif
    
    return image;
}

+ (instancetype)skinImageNamed:(NSString *)name
                      inBundle:(NSBundle *)resourceBundle {
    UIImage *image = [UIImage imageNamed:name inBundle:resourceBundle compatibleWithTraitCollection:nil];
#if DEBUG
//    NSAssert(image != nil, @"⚠️skinImageNamed (%@) is nil, in bundle (%@)", name, resourceBundle);
#endif
    return image;
}

// MARK: -

+ (instancetype _Nullable)imageWithColorStyle:(HTColorStyle *)colorStyle
                                         size:(CGSize)size {
    UIImage *image = nil;
    if (colorStyle.gradientColor) {// TODO: 图片缓存
        image = [self sk_imageWithGradientColor:colorStyle.gradientColor size:size];
    } else if (colorStyle.color) {
        image = [self sk_imageWithColor:colorStyle.color size:size];
    }
    
    return image;
}

- (UIImage *)imageWithAlpha:(CGFloat)alpha {
    //create drawing context
    UIGraphicsBeginImageContextWithOptions(self.size, NO, 0.0f);
    
    //draw with alpha
    [self drawAtPoint:CGPointZero blendMode:kCGBlendModeNormal alpha:alpha];
    
    //capture resultant image
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //return image
    return image;
}

+ (UIImage *_Nullable)sk_imageWithColor:(UIColor *)color
                                   size:(CGSize)size {
    CGFloat cornerRadius = 8.0;
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIBezierPath *roundedRect = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:cornerRadius];
    roundedRect.lineWidth = 0;
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0.0f);
    [color setFill];
    [roundedRect fill];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return [image resizableImageWithCapInsets:UIEdgeInsetsMake(cornerRadius, cornerRadius, cornerRadius, cornerRadius)];
}

+ (UIImage *_Nullable)sk_imageWithGradientColor:(HTGradientColor *)gradientColor
                                           size:(CGSize)size {
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    
    CAGradientLayer *gradientLayer = [[CAGradientLayer alloc] init];
    
    NSArray<UIColor *> *colors = gradientColor.colors;
    NSArray<NSValue *> *startEndPoint = gradientColor.startEndPoint;
    NSArray<NSNumber *> *locations = gradientColor.locations;
    NSAssert(colors.count >= 2 && colors.count == locations.count, @"❌colors.count != locations.count");
    NSAssert(startEndPoint.count == 2, @"❌startEndPoint.count != 2");
    NSAssert(locations.firstObject.floatValue >= 0 && locations.lastObject.floatValue <= 1, @"❌locations invalid");
    gradientLayer.colors = [colors sk_map:^id _Nonnull(UIColor * _Nonnull obj, NSUInteger idx) {
        return (__bridge id)obj.CGColor;
    }];
    gradientLayer.startPoint = startEndPoint.firstObject.CGPointValue;
    gradientLayer.endPoint = startEndPoint.lastObject.CGPointValue;
    gradientLayer.locations = locations;
    
    gradientLayer.frame = rect;
    
    UIGraphicsBeginImageContext(size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [gradientLayer renderInContext:context];
    
    CGPathRef path = CGPathCreateWithRoundedRect(rect, 8, 8, nil);
    CGContextAddPath(context, path);
    CGContextClip(context);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    CGPathRelease(path);
    UIGraphicsEndImageContext();
    return image;
}

@end
