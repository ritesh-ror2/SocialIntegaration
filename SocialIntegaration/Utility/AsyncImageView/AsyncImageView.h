
#ifndef AH_RETAIN
#if __has_feature(objc_arc)
#define AH_RETAIN(x) x
#define AH_RELEASE(x)
#define AH_AUTORELEASE(x) x
#define AH_SUPER_DEALLOC
#else
#define __AH_WEAK
#define AH_WEAK assign
#define AH_RETAIN(x) [x retain]
#define AH_RELEASE(x) [x release]
#define AH_AUTORELEASE(x) x//[x autorelease]
#define AH_SUPER_DEALLOC [super dealloc]
#endif
#endif

//  ARC Helper ends


#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

extern NSString *const AsyncImageLoadDidFinish;
extern NSString *const AsyncImageLoadDidFail;

extern NSString *const AsyncImageImageKey;
extern NSString *const AsyncImageURLKey;
extern NSString *const AsyncImageCacheKey;
extern NSString *const AsyncImageErrorKey;


@interface AsyncImageCache : NSObject

+ (AsyncImageCache *)sharedCache;

@property (nonatomic, assign) BOOL useImageNamed;
@property (nonatomic, assign) NSUInteger countLimit;

- (UIImage *)imageForURL:(NSURL *)URL;
- (void)setImage:(UIImage *)image forURL:(NSURL *)URL;
- (void)removeImageForURL:(NSURL *)URL;
- (void)clearCache;

@end


@interface AsyncImageLoader : NSObject

+ (AsyncImageLoader *)sharedLoader;

@property (nonatomic, strong) AsyncImageCache *cache;
@property (nonatomic, assign) NSUInteger concurrentLoads;
@property (nonatomic, assign) NSTimeInterval loadingTimeout;
@property (nonatomic, assign) BOOL decompressImages;

- (void)loadImageWithURL:(NSURL *)URL target:(id)target success:(SEL)success failure:(SEL)failure;
- (void)loadImageWithURL:(NSURL *)URL target:(id)target action:(SEL)action;
- (void)loadImageWithURL:(NSURL *)URL;
- (void)cancelLoadingURL:(NSURL *)URL target:(id)target action:(SEL)action;
- (void)cancelLoadingURL:(NSURL *)URL target:(id)target;
- (void)cancelLoadingURL:(NSURL *)URL;
- (NSURL *)URLForTarget:(id)target action:(SEL)action;

@end


@interface UIImageView(AsyncImageView)

@property (nonatomic, strong) NSURL *imageURL;
//@property (nonatomic) BOOL isExplore;

@end

@interface AsyncImageView : UIImageView

@property (nonatomic, assign) BOOL showActivityIndicator;
@property (nonatomic, assign) UIActivityIndicatorViewStyle activityIndicatorStyle;
@property (nonatomic, assign) BOOL crossfadeImages;
@property (nonatomic, assign) NSTimeInterval crossfadeDuration;

@end
