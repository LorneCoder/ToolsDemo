//
//  NSURLProtocolCustom.m
//  QianDaoDemo
//
//  Created by gaojianlong on 2019/8/12.
//  Copyright © 2019 gaojianlong. All rights reserved.
//

#import "NSURLProtocolCustom.h"
#import <Foundation/Foundation.h>
#import <CoreFoundation/CoreFoundation.h>
#import <MobileCoreServices/MobileCoreServices.h>

@implementation NSURLProtocolCustom


+ (BOOL)canInitWithRequest:(NSURLRequest *)request
{
    // 这里是html 渲染时候入口，来处理自定义标签 如 "myapp",若return YES 则会执行接下来的 -startLoading方法
    NSLog(@"request.URL.scheme === %@", request.URL.scheme);
    NSLog(@"request.URL === %@", request.URL);
    NSLog(@"后缀：%@", [request.URL.absoluteString lastPathComponent]);
    
    NSString *lastStr = [request.URL.absoluteString lastPathComponent];
    if ([lastStr caseInsensitiveCompare:@"1.jpg"] == NSOrderedSame) {
        return YES;
    }
    
    return NO;
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request
{
    NSLog(@"canonicalRequestForRequest");
    return request;
}

- (void)startLoading
{
    //处理自定义标签，并实现内嵌本地资源
    NSLog(@"startLoading");
    NSLog(@"%@", super.request.URL);
    
    
//    // 得到//image1.png"
//    NSString *url = super.request.URL.resourceSpecifier;
//    //去掉 //前缀（）
//    url = [url substringFromIndex:2];//image1.png
//
//    //若是app 协议 需要添加www (这里是我们自己业务上的吹)
//    if ([super.request.URL.scheme caseInsensitiveCompare:@"app"]) {
//        url = [[NSString alloc] initWithFormat:@"www/%@",url];
//    }
//
//
//    //NSString *path=  [[NSBundle mainBundle] pathForResource:@"www/image1.png" ofType:nil];
//    NSString *path = [[NSBundle mainBundle] pathForResource:url ofType:nil];//这里是获取本地资源路径 如 ：png,js 等
//    if (!path) {
//        return;
//    }
//
//    //根据路径获取MIMEType   （以下函数方法需要添加.h文件的引用，）
//    // Get the UTI from the file's extension:
//    CFStringRef pathExtension = (__bridge_retained CFStringRef)[path pathExtension];
//    CFStringRef type = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, pathExtension, NULL);
//    CFRelease(pathExtension);
//
//    // The UTI can be converted to a mime type:
//    NSString *mimeType = (__bridge_transfer NSString *)UTTypeCopyPreferredTagWithClass(type, kUTTagClassMIMEType);
//    if (type != NULL) {
//        CFRelease(type);
//    }
//
//    // 这里需要用到MIMEType
    NSURLResponse *response = [[NSURLResponse alloc] initWithURL:super.request.URL
                                                        MIMEType:@"png"
                                           expectedContentLength:-1
                                                textEncodingName:nil];

    
    NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"png"];
    NSData *data = [NSData dataWithContentsOfFile:imagePath];//加载本地资源
    //硬编码 开始嵌入本地资源到web中
    [[self client] URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
    [[self client] URLProtocol:self didLoadData:data];
    [[self client] URLProtocolDidFinishLoading:self];
}

- (void)stopLoading
{
    NSLog(@"stopLoading");
}

@end
