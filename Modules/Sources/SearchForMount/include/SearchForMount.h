#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

//! Project version number for SearchForMount.
FOUNDATION_EXPORT double SearchForMountVersionNumber;

//! Project version string for SearchForMount.
FOUNDATION_EXPORT const unsigned char SearchForMountVersionString[];

@interface PathInfo : NSObject

@property NSString * mountPath;
@property NSString * mountUrl;
@property NSString * mountType;

- (nullable instancetype) initWithPath: (NSString *)aPath;

@end

NS_ASSUME_NONNULL_END
