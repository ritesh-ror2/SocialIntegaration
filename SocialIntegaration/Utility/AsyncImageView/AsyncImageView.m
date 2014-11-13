
#import "AsyncImageView.h"
#import <objc/message.h>
#import <QuartzCore/QuartzCore.h>


NSString *const AsyncImageLoadDidFinish = @"AsyncImageLoadDidFinish";
NSString *const AsyncImageLoadDidFail = @"AsyncImageLoadDidFail";
NSString *const AsyncImageTargetReleased = @"AsyncImageTargetReleased";

NSString *const AsyncImageImageKey = @"image";
NSString *const AsyncImageURLKey = @"URL";
NSString *const AsyncImageCacheKey = @"cache";
NSString *const AsyncImageErrorKey = @"error";


@interface AsyncImageCache ()

@property (nonatomic, strong) NSCache *cache;

@end


@implementation AsyncImageCache

@synthesize cache;
@synthesize useImageNamed;

+ (AsyncImageCache *)sharedCache
{
	static AsyncImageCache *sharedInstance = nil;
	if (sharedInstance == nil)
	{
		sharedInstance = [[self alloc] init];
	}
	return sharedInstance;
}

- (id)init
{
	if ((self = [super init]))
	{
		useImageNamed = YES;
		cache = [[NSCache alloc] init];
	}
	return self;
}

- (void)setCountLimit:(NSUInteger)countLimit
{
	cache.countLimit = countLimit;
}

- (NSUInteger)countLimit
{
	return cache.countLimit;
}

- (UIImage *)imageForURL:(NSURL *)URL
{
	if (useImageNamed && [URL isFileURL])
	{
		NSString *path = [URL path];
		NSString *imageName = [path lastPathComponent];
		NSString *directory = [path stringByDeletingLastPathComponent];
		if ([[[NSBundle mainBundle] resourcePath] isEqualToString:directory])
		{
			return [UIImage imageNamed:imageName];
		}
	}
	return [cache objectForKey:URL];
}

- (void)setImage:(UIImage *)image forURL:(NSURL *)URL
{
	if (useImageNamed && [URL isFileURL])
	{
		NSString *path = [URL path];
		NSString *directory = [path stringByDeletingLastPathComponent];
		if ([[[NSBundle mainBundle] resourcePath] isEqualToString:directory])
		{
			//do not store in cache
			return;
		}
	}
	[cache setObject:image forKey:URL];
}

- (void)removeImageForURL:(NSURL *)URL
{
	[cache removeObjectForKey:URL];
}

- (void)clearCache
{
	//remove objects that aren't in use
	[cache removeAllObjects];
}

- (void)dealloc
{
	AH_RELEASE(cache);
	AH_SUPER_DEALLOC;
}

@end


@interface AsyncImageConnection : NSObject

@property (nonatomic, strong) NSURLConnection *connection;
@property (nonatomic, strong) NSMutableData *data;
@property (nonatomic, strong) NSURL *URL;
@property (nonatomic, strong) AsyncImageCache *cache;
@property (nonatomic, strong) id target;
@property (nonatomic, assign) SEL success;
@property (nonatomic, assign) SEL failure;
@property (nonatomic, assign) BOOL decompressImage;
@property (nonatomic, readonly, getter = isLoading) BOOL loading;
@property (nonatomic, readonly) BOOL cancelled;

+ (AsyncImageConnection *)connectionWithURL:(NSURL *)URL
                                      cache:(AsyncImageCache *)cache
							  target:(id)target
							 success:(SEL)success
							 failure:(SEL)failure
					   decompressImage:(BOOL)decompressImage;

- (AsyncImageConnection *)initWithURL:(NSURL *)URL
                                cache:(AsyncImageCache *)cache
						 target:(id)target
						success:(SEL)success
						failure:(SEL)failure
				  decompressImage:(BOOL)decompressImage;

- (void)start;
- (void)cancel;
- (BOOL)isInCache;

@end


@implementation AsyncImageConnection

@synthesize connection;
@synthesize data;
@synthesize URL;
@synthesize cache;
@synthesize target;
@synthesize success;
@synthesize failure;
@synthesize decompressImage;
@synthesize loading;
@synthesize cancelled;


+ (AsyncImageConnection *)connectionWithURL:(NSURL *)URL
                                      cache:(AsyncImageCache *)_cache
							  target:(id)target
							 success:(SEL)_success
							 failure:(SEL)_failure
					   decompressImage:(BOOL)_decompressImage
{
	return AH_AUTORELEASE([[self alloc] initWithURL:URL
									  cache:_cache
									 target:target
									success:_success
									failure:_failure
							  decompressImage:_decompressImage]);
}

- (AsyncImageConnection *)initWithURL:(NSURL *)_URL
                                cache:(AsyncImageCache *)_cache
						 target:(id)_target
						success:(SEL)_success
						failure:(SEL)_failure
				  decompressImage:(BOOL)_decompressImage
{
	if ((self = [self init]))
	{
		self.URL = _URL;
		self.cache = _cache;
		self.target = _target;
		self.success = _success;
		self.failure = _failure;
		self.decompressImage = _decompressImage;
	}
	return self;
}

- (BOOL)isInCache
{
	return [cache imageForURL:URL] != nil;
}

- (void)loadFailedWithError:(NSError *)error
{
	loading = NO;
	cancelled = NO;
	[[NSNotificationCenter defaultCenter] postNotificationName:AsyncImageLoadDidFail
											  object:target
											userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
													URL, AsyncImageURLKey,
													error, AsyncImageErrorKey,
													nil]];
}

- (void)cacheImage:(UIImage *)image
{
	if (!cancelled)
	{
		if (image)
		{
			//image = [UIImage imageNamed:@"ss.jpg"];
			//image = [self trimTopBorder: image];
			//image = [self trimBottomBorder: image];

			[cache setImage:image forURL:URL];
		}
		
		NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:
								   image, AsyncImageImageKey,
								   URL, AsyncImageURLKey,
								   nil];
		if (cache)
		{
			[userInfo setObject:cache forKey:AsyncImageCacheKey];
		}
		
		loading = NO;
		[[NSNotificationCenter defaultCenter] postNotificationName:AsyncImageLoadDidFinish
												  object:target
												userInfo:AH_AUTORELEASE([userInfo copy])];
	}
	else
	{
		loading = NO;
		cancelled = NO;
	}
}

struct pixel {
	unsigned char r, g, b, a;
};

- (UIImage *) trimTopBorder: (UIImage*) image
{
	//NSLog(@"size = %@",NSStringFromCGSize(image.size));
	struct pixel* pixels = (struct pixel*) calloc(1, image.size.width * image.size.height * sizeof(struct pixel));
	if (pixels != nil)
	{
		// Create a new bitmap
		CGContextRef context = CGBitmapContextCreate((void*) pixels,
											image.size.width,
											image.size.height,
											8,
											image.size.width * 4,
											CGImageGetColorSpace(image.CGImage),
											(int)kCGImageAlphaPremultipliedLast
											);
		
		if (context != NULL)
		{
			CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, image.size.width, image.size.height), image.CGImage);
			
			NSInteger totalBlackRows = 0;
			int blackOffset = 10;
			for (size_t y = 0; y < image.size.height; y++) {
				
				NSInteger blackPixelsPerRow = 0;
				for (size_t x = 0; x < image.size.width; x++) {
					//NSLog(@"%d %d %d %d",pixels->r,pixels->g,pixels->b,pixels->a);
					if (pixels->r <= blackOffset && pixels->g <= blackOffset && pixels->b <= blackOffset && pixels->a == 255) {
						blackPixelsPerRow++;
					}
					
					pixels++;
				}
				if (blackPixelsPerRow != image.size.width) {
					break;
				}
				else {
					totalBlackRows++;
				}
			}
			
			CGContextRelease(context);
			
			if (totalBlackRows > 40) {
				totalBlackRows = 40;
			}
			
			totalBlackRows = totalBlackRows * 0.70;
			void * newData = NULL;
			CGContextRef newContext = CKBitmapContextAndDataCreate(CGSizeMake(image.size.width, image.size.height - totalBlackRows), &newData);
			CGRect rect = CGRectMake(0, totalBlackRows, image.size.width, image.size.height);
			CGContextDrawImage(newContext, rect, [image CGImage]);
			CGImageRef newImage = CGBitmapContextCreateImage(newContext);
			CGContextRelease(newContext);
			free(newData);
			if ([[UIImage class] respondsToSelector:@selector(imageWithCGImage:scale:orientation:)])
				image = [UIImage imageWithCGImage:newImage scale:[image scale] orientation:UIImageOrientationUp];
			else
				image = [UIImage imageWithCGImage:newImage];
			CGImageRelease(newImage);
			//NSLog(@"size frst= %@",NSStringFromCGSize(image.size));
			return image;
		}
	}
	return image;
}

- (UIImage *)trimBottomBorder:(UIImage*)image
{
	//NSLog(@"size = %@",NSStringFromCGSize(image.size));
	struct pixel* pixels = (struct pixel*) calloc(1, image.size.width * image.size.height * sizeof(struct pixel));
	if (pixels != nil)
	{
		// Create a new bitmap
		CGContextRef context = CGBitmapContextCreate((void*) pixels,
											image.size.width,
											image.size.height,
											8,
											image.size.width * 4,
											CGImageGetColorSpace(image.CGImage),
											(int)kCGImageAlphaPremultipliedLast
											);
		
		if (context != NULL)
		{
			CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, image.size.width, image.size.height), image.CGImage);
			
			NSInteger totalBlackRows = 0;
			
			for (size_t y = 0; y < image.size.height; y++) {
				
				for (size_t x = 0; x < image.size.width; x++) {
					
					pixels++;
				}
			}
			
			pixels--;
			int blackOffset = 10;
			for (size_t y = image.size.height; y > 0; y--) {
				
				NSInteger blackPixelsPerRow = 0;
				NSInteger transPixelsPerRow = 0;
				for (size_t x = image.size.width; x > 0; x--) {
					
					//NSLog(@"%d %d %d %d",pixels->r,pixels->g,pixels->b,pixels->a);
					if (pixels->r <= blackOffset && pixels->g <= blackOffset && pixels->b <= blackOffset && pixels->a == 255) {
						blackPixelsPerRow++;
					}
					if (pixels->r == 0 && pixels->g == 0 && pixels->b == 0 && pixels->a == 0) {
						transPixelsPerRow++;
					}
					
					pixels--;
				}
				if (transPixelsPerRow == image.size.width) {
					continue;
				}
				else if (blackPixelsPerRow != image.size.width) {
					break;
				}
				else {
					totalBlackRows++;
				}
			}
			
			CGContextRelease(context);
			
			if (totalBlackRows > 40) {
				totalBlackRows = 40;
			}
			
			CGRect rect = CGRectMake(0, 0, image.size.width, image.size.height - (2 * totalBlackRows));
			image = [self imageWithImage:image cropInRect:rect];
			//NSLog(@"size scd= %@",NSStringFromCGSize(image.size));
			return image;
		}
	}
	return image;
}

- (UIImage *)imageWithImage:(UIImage *)image cropInRect:(CGRect)rect {
	NSParameterAssert(image != nil);
	
	if (CGPointEqualToPoint(CGPointZero, rect.origin) && CGSizeEqualToSize(rect.size, image.size)) {
		return image;
	}
	
	UIGraphicsBeginImageContextWithOptions(rect.size, NO, 1);
	[image drawAtPoint:(CGPoint){-rect.origin.x, -rect.origin.y}];
	UIImage *croppedImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return croppedImage;
}

#define kNumberOfComponents (4)
#define kBytesPerComponent (8)
#define kBytesPerPixel (kNumberOfComponents)

CGContextRef CKBitmapContextAndDataCreate(CGSize size, void ** data) {
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	if(colorSpace == NULL) {
		printf("Error allocating color space.\n");
		return NULL;
	}
	
	uint8_t *bitmapData = NULL;
	if (data)
	{
		bitmapData = (uint8_t *)calloc((size_t)(size.width * size.height * kNumberOfComponents), sizeof(uint8_t));
		*data = bitmapData;
	}
	
	CGContextRef context = CGBitmapContextCreate(bitmapData,
										(size_t)size.width,
										(size_t)size.height,
										kBytesPerComponent,
										(size_t)size.width * kBytesPerPixel,
										colorSpace,
										(int)kCGImageAlphaPremultipliedLast);
	CGColorSpaceRelease(colorSpace);
	
	if(context == NULL) {
		printf("Context not created!\n");
		return NULL;
	}
	
	return context;
}


- (void)decompressImageInBackground:(UIImage *)image
{
	@synchronized ([self class])
	{
		if (!cancelled && decompressImage)
		{
			//force image decompression
			UIGraphicsBeginImageContext(CGSizeMake(1, 1));
			[image drawAtPoint:CGPointZero];
			UIGraphicsEndImageContext();
		}
		
		//add to cache (may be cached already but it doesn't matter)
		[self performSelectorOnMainThread:@selector(cacheImage:)
						   withObject:image
						waitUntilDone:YES];
	}
}

- (void)processDataInBackground:(NSData *)_data
{
	@synchronized ([self class])
	{
		if (!cancelled)
		{
			UIImage *image = [[UIImage alloc] initWithData:_data];
			if (image)
			{
				[self decompressImageInBackground:image];
				AH_RELEASE(image);
			}
			else
			{
				@autoreleasepool
				{
					NSError *error = [NSError errorWithDomain:@"AsyncImageLoader" code:0 userInfo:[NSDictionary dictionaryWithObject:@"Invalid image data" forKey:NSLocalizedDescriptionKey]];
					[self performSelectorOnMainThread:@selector(loadFailedWithError:) withObject:error waitUntilDone:YES];
				}
			}
		}
		else
		{
			//clean up
			[self performSelectorOnMainThread:@selector(cacheImage:)
							   withObject:nil
							waitUntilDone:YES];
		}
	}
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	self.data = [NSMutableData data];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)_data
{
	//check for cached image
	UIImage *image = [cache imageForURL:URL];
	if (image)
	{
		[self cancel];
		[self performSelectorInBackground:@selector(decompressImageInBackground:) withObject:image];
		return;
	}
	
	//add data
	[data appendData:_data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	[self performSelectorInBackground:@selector(processDataInBackground:) withObject:data];
	self.connection = nil;
	self.data = nil;
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	self.connection = nil;
	self.data = nil;
	[self loadFailedWithError:error];
}

- (void)start
{
	if (loading && !cancelled)
	{
		return;
	}
	
	//begin loading
	loading = YES;
	cancelled = NO;
	
	//check for nil URL
	if (URL == nil)
	{
		[self cacheImage:nil];
		return;
	}
	
	//check for cached image
	UIImage *image = [cache imageForURL:URL];
	if (image)
	{
		[self performSelectorInBackground:@selector(decompressImageInBackground:) withObject:image];
		return;
	}
	
	//begin load
	NSURLRequest *request = [NSURLRequest requestWithURL:URL
									 cachePolicy:NSURLCacheStorageNotAllowed
								  timeoutInterval:[AsyncImageLoader sharedLoader].loadingTimeout];
	
	connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
	[connection scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
	[connection start];
}

- (void)cancel
{
	cancelled = YES;
	[connection cancel];
	self.connection = nil;
	self.data = nil;
}

- (void)dealloc
{
	AH_RELEASE(connection);
	AH_RELEASE(data);
	AH_RELEASE(URL);
	AH_RELEASE(target);
	AH_SUPER_DEALLOC;
}

@end


@interface AsyncImageLoader ()

@property (nonatomic, strong) NSMutableArray *connections;

@end


@implementation AsyncImageLoader

@synthesize cache;
@synthesize connections;
@synthesize concurrentLoads;
@synthesize loadingTimeout;
@synthesize decompressImages;

+ (AsyncImageLoader *)sharedLoader
{
	static AsyncImageLoader *sharedInstance = nil;
	if (sharedInstance == nil)
	{
		sharedInstance = [[self alloc] init];
	}
	return sharedInstance;
}

- (AsyncImageLoader *)init
{
	if ((self = [super init]))
	{
		cache = AH_RETAIN([AsyncImageCache sharedCache]);
		concurrentLoads = 2;
		loadingTimeout = 60;
		decompressImages = NO;
		connections = [[NSMutableArray alloc] init];
		[[NSNotificationCenter defaultCenter] addObserver:self
										 selector:@selector(imageLoaded:)
											name:AsyncImageLoadDidFinish
										   object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self
										 selector:@selector(imageFailed:)
											name:AsyncImageLoadDidFail
										   object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self
										 selector:@selector(targetReleased:)
											name:AsyncImageTargetReleased
										   object:nil];
	}
	return self;
}

- (void)updateQueue
{
	//start connections
	NSInteger count = 0;
	for (AsyncImageConnection *connection in connections)
	{
		if (![connection isLoading])
		{
			if ([connection isInCache])
			{
				[connection start];
			}
			else if (count < concurrentLoads)
			{
				count ++;
				[connection start];
			}
		}
	}
}

- (void)imageLoaded:(NSNotification *)notification
{
	//complete connections for URL
	NSURL *URL = [notification.userInfo objectForKey:AsyncImageURLKey];
	for (int i = (int)[connections count] - 1; i >= 0; i--)
	{
		AsyncImageConnection *connection = [connections objectAtIndex:i];
		if (connection.URL == URL || [connection.URL isEqual:URL])
		{
			//cancel earlier connections for same target/action
			for (int j = i - 1; j >= 0; j--)
			{
				AsyncImageConnection *earlier = [connections objectAtIndex:j];
				if (earlier.target == connection.target &&
				    earlier.success == connection.success)
				{
					[earlier cancel];
					[connections removeObjectAtIndex:j];
					i--;
				}
			}
			
			//cancel connection (in case it's a duplicate)
			[connection cancel];
			
			//perform action
			UIImage *image = [notification.userInfo objectForKey:AsyncImageImageKey];
			
			objc_msgSend(connection.target, connection.success, image, connection.URL);
			
			//remove from queue
			[connections removeObjectAtIndex:i];
		}
	}
	
	//update the queue
	[self updateQueue];
}

- (void)imageFailed:(NSNotification *)notification
{
	//remove connections for URL
	NSURL *URL = [notification.userInfo objectForKey:AsyncImageURLKey];
	for (int i = (int)[connections count] - 1; i >= 0; i--)
	{
		AsyncImageConnection *connection = [connections objectAtIndex:i];
		if ([connection.URL isEqual:URL])
		{
			//cancel connection (in case it's a duplicate)
			[connection cancel];
			
			//perform failure action
			if (connection.failure)
			{
				NSError *error = [notification.userInfo objectForKey:AsyncImageErrorKey];
				objc_msgSend(connection.target, connection.failure, error, URL);
			}
			
			//remove from queue
			[connections removeObjectAtIndex:i];
		}
	}
	
	//update the queue
	[self updateQueue];
}

- (void)targetReleased:(NSNotification *)notification
{
	//remove connections for URL
	id target = [notification object];
	for (int i = (int)[connections count] - 1; i >= 0; i--)
	{
		AsyncImageConnection *connection = [connections objectAtIndex:i];
		if (connection.target == target)
		{
			//cancel connection
			[connection cancel];
			[connections removeObjectAtIndex:i];
		}
	}
	
	//update the queue
	[self updateQueue];
}

- (void)loadImageWithURL:(NSURL *)URL target:(id)target success:(SEL)success failure:(SEL)failure
{
	//create new connection
	[connections addObject:[AsyncImageConnection connectionWithURL:URL
												  cache:cache
												 target:target
												success:success
												failure:failure
										  decompressImage:decompressImages]];
	[self updateQueue];
}

- (void)loadImageWithURL:(NSURL *)URL target:(id)target action:(SEL)action
{
	[self loadImageWithURL:URL target:target success:action failure:NULL];
}

- (void)loadImageWithURL:(NSURL *)URL
{
	[self loadImageWithURL:URL target:nil success:NULL failure:NULL];
}

- (void)cancelLoadingURL:(NSURL *)URL target:(id)target action:(SEL)action
{
	for (int i = (int)[connections count] - 1; i >= 0; i--)
	{
		AsyncImageConnection *connection = [connections objectAtIndex:i];
		if ([connection.URL isEqual:URL] && connection.target == target && connection.success == action)
		{
			[connection cancel];
			[connections removeObjectAtIndex:i];
		}
	}
}

- (void)cancelLoadingURL:(NSURL *)URL target:(id)target
{
	for (int i = (int)[connections count] - 1; i >= 0; i--)
	{
		AsyncImageConnection *connection = [connections objectAtIndex:i];
		if ([connection.URL isEqual:URL] && connection.target == target)
		{
			[connection cancel];
			[connections removeObjectAtIndex:i];
		}
	}
}

- (void)cancelLoadingURL:(NSURL *)URL
{
	for (int i = (int)[connections count] - 1; i >= 0; i--)
	{
		AsyncImageConnection *connection = [connections objectAtIndex:i];
		if ([connection.URL isEqual:URL])
		{
			[connection cancel];
			[connections removeObjectAtIndex:i];
		}
	}
}

- (NSURL *)URLForTarget:(id)target action:(SEL)action
{
	//return the most recent image URL assigned to the target
	//this is not neccesarily the next image that will be assigned
	for (int i = (int)[connections count] - 1; i >= 0; i--)
	{
		AsyncImageConnection *connection = [connections objectAtIndex:i];
		if (connection.target == target && connection.success == action)
		{
			
			return connection.URL;
			//return AH_AUTORELEASE(AH_RETAIN(connection.URL));
		}
	}
	return nil;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	AH_RELEASE(cache);
	AH_RELEASE(connections);
	AH_SUPER_DEALLOC;
}

@end


@implementation UIImageView(AsyncImageView)

- (void)setImageURL:(NSURL *)imageURL
{
	[[AsyncImageLoader sharedLoader] loadImageWithURL:imageURL target:self action:@selector(setImage:)];
}

- (NSURL *)imageURL
{
	return [[AsyncImageLoader sharedLoader] URLForTarget:self action:@selector(setImage:)];
}

@end


@interface AsyncImageView ()

@property (nonatomic, strong) UIActivityIndicatorView *activityView;

@end


@implementation AsyncImageView

@synthesize showActivityIndicator;
@synthesize activityIndicatorStyle;
@synthesize crossfadeImages;
@synthesize crossfadeDuration;
@synthesize activityView;

- (void)setUp
{
	showActivityIndicator = (self.image == nil);
	activityIndicatorStyle = UIActivityIndicatorViewStyleGray;
	crossfadeImages = YES;
	crossfadeDuration = 0.4;
//	self.layer.borderWidth = 1.0;
//	self.layer.borderColor = [UIColor blackColor].CGColor;
//	self.layer.cornerRadius = 2.0;
//	self.clipsToBounds = YES;
}

- (id)initWithFrame:(CGRect)frame
{
	if ((self = [super initWithFrame:frame]))
	{
		[self setUp];
	}
	return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	if ((self = [super initWithCoder:aDecoder]))
	{
		[self setUp];
	}
	return self;
}

- (void)setImageURL:(NSURL *)imageURL
{
	super.imageURL = imageURL;
	if (showActivityIndicator && !self.image)
	{
		if (activityView == nil)
		{
			activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:activityIndicatorStyle];
			activityView.hidesWhenStopped = YES;
			activityView.center = CGPointMake(self.bounds.size.width / 2.0f, self.bounds.size.height / 2.0f);
			activityView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
			[self addSubview:activityView];
			
		}
		[activityView startAnimating];
	}
}

- (void)setActivityIndicatorStyle:(UIActivityIndicatorViewStyle)style
{
	activityIndicatorStyle = style;
	[activityView removeFromSuperview];
	self.activityView = nil;
}

- (void)setImage:(UIImage *)image
{
	if (crossfadeImages)
	{
		CATransition *animation = [CATransition animation];
		animation.type = kCATransitionFade;
		animation.duration = crossfadeDuration;
		[self.layer addAnimation:animation forKey:nil];
	}
	
	super.image = image;
        
    self.contentMode = UIViewContentModeScaleAspectFit;
    super.contentMode = UIViewContentModeScaleAspectFit;

	[activityView stopAnimating];
}

- (UIImage*)maskImage:(UIImage *) image withMask:(UIImage *) mask
{
	CGImageRef imageReference = image.CGImage;
	CGImageRef maskReference = mask.CGImage;
	
	CGImageRef imageMask = CGImageMaskCreate(CGImageGetWidth(maskReference),
									 CGImageGetHeight(maskReference),
									 CGImageGetBitsPerComponent(maskReference),
									 CGImageGetBitsPerPixel(maskReference),
									 CGImageGetBytesPerRow(maskReference),
									 CGImageGetDataProvider(maskReference),
									 NULL, // Decode is null
									 YES // Should interpolate
									 );
	
	CGImageRef maskedReference = CGImageCreateWithMask(imageReference, imageMask);
	CGImageRelease(imageMask);
	
	UIImage *maskedImage = [UIImage imageWithCGImage:maskedReference];
	CGImageRelease(maskedReference);
	
	return maskedImage;
}

- (UIImage*)imageWithImage:(UIImage*)image scaledToSizeKeepingAspect:(CGSize)newSize
{
	// Create a graphics image context
	if (newSize.width==300 && newSize.height==300) {
		if (image.size.width<300 && image.size.height<300) {
			return image;
		}
	}
	//NSLog(@"image size -: %@",NSStringFromCGSize(image.size));
	float imgHeight = image.size.height;
	float imgWeight = image.size.width;
	float fact = 0.0;
	if (imgHeight>imgWeight) {
		fact = imgHeight/newSize.width;
	}else{
		fact = imgWeight / newSize.height;
	}
	imgHeight = imgHeight / fact;
	imgWeight = imgWeight / fact;
	//NSLog(@" >>  1  %@",NSStringFromCGSize(newSize));
	newSize  = CGSizeMake(imgWeight, imgHeight);
	//NSLog(@" >>> 2  %@",NSStringFromCGSize(newSize));
	UIGraphicsBeginImageContext(newSize);
	
	// Tell the old image to draw in this new context, with the desired
	// new size
	[image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
	
	// Get the new image from the context
	UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
	
	// End the context
	UIGraphicsEndImageContext();
	
	// Return the new image.
	return newImage;
}
- (void)dealloc
{
	[[AsyncImageLoader sharedLoader] cancelLoadingURL:self.imageURL target:self];
	AH_RELEASE(activityView);
	AH_SUPER_DEALLOC;
}

@end
