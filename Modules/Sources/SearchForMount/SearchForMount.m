#import <Foundation/Foundation.h>
#import <sys/param.h>
#import <sys/mount.h>

#import "SearchForMount.h"

@implementation PathInfo

- (instancetype)initWithPath:(NSString *)aPath {
    const char * pathString = [aPath cStringUsingEncoding: NSUTF8StringEncoding];
    if (!pathString) {
        return NULL;
    }
    
    struct statfs fileSystemInfo;
    if (statfs(pathString, &fileSystemInfo) != 0) {
        return NULL;
    }
    
    self = [super init];
    if (self) {
        _mountType = [NSString stringWithCString: fileSystemInfo.f_fstypename encoding: NSUTF8StringEncoding];
        _mountPath = [NSString stringWithCString: fileSystemInfo.f_mntonname encoding: NSUTF8StringEncoding];
        _mountUrl = [NSString stringWithCString: fileSystemInfo.f_mntfromname encoding: NSUTF8StringEncoding];
    }
    return self;
}

@end
