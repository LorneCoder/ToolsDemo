//
//  PayController.m
//  QianDaoDemo
//
//  Created by gaojianlong on 2020/8/13.
//  Copyright © 2020 gaojianlong. All rights reserved.
//

#import "PayController.h"
#import <WebKit/WebKit.h>


@interface PayController () <WKUIDelegate, WKNavigationDelegate>

@property (nonatomic, strong) WKWebView *webview;

@end

@implementation PayController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"支付";
    [self.view addSubview:self.webview];
    
    //NSURL *url = [NSURL URLWithString:@"https://wxpay.wxutil.com/mch/pay/h5.v2.php"];//微信官方体验链接
    NSURL *alipay_url = [NSURL URLWithString:@"https://www.amazon.cn/"];
    NSURLRequest *request = [NSURLRequest requestWithURL:alipay_url];
    [self.webview loadRequest:request];
}

#pragma mark -
#pragma mark - WKNavigationDelegate

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation
{
    NSLog(@"开始加载");
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation
{
    NSLog(@"加载完成");
    [webView evaluateJavaScript:@"document.title" completionHandler:^(id object, NSError *error) {
        if (object) {
            NSLog(@"标题：%@", object);
        }
    }];
}

// 根据WebView对于即将跳转的HTTP请求头信息和相关信息来决定是否跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    //先默认允许加载
    WKNavigationActionPolicy actionPolicy = WKNavigationActionPolicyAllow;
    NSString *urlString = [[navigationAction.request URL] absoluteString];
    urlString = [urlString stringByRemovingPercentEncoding];
    
    //根据跳转URL确定是否需要调起微信App
    if([urlString containsString:@"weixin://wap/pay?"] && [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:urlString]]) {
        //微信支付
        actionPolicy = WKNavigationActionPolicyCancel;//不再加载网页，微信App里处理
        NSURL *url = [NSURL URLWithString:urlString];
      
        //区分版本打开应用并传参
        if([[UIApplication sharedApplication] respondsToSelector:@selector(openURL:options:completionHandler:)]) {
            if (@available(iOS 10.0, *)) {
                [[UIApplication sharedApplication] openURL:url options:@{UIApplicationOpenURLOptionUniversalLinksOnly: @NO} completionHandler:^(BOOL success) {
                    
                }];
            } else {
                [[UIApplication sharedApplication] openURL:url];
            }
        } else{
            [[UIApplication sharedApplication] openURL:url];
        }
    }
    else if ([urlString hasPrefix:@"alipays://"] || [urlString hasPrefix:@"alipay://"]) {
        //支付宝
        //1.以?号来切割字符串
        NSArray *urlBaseArr = [urlString componentsSeparatedByString:@"?"];
        NSString *urlBaseStr = urlBaseArr.firstObject;
        NSString *urlNeedDecode = urlBaseArr.lastObject;
        //2.将截取以后的Str，做一下URLDecode，方便处理
        NSMutableString *afterDecodeStr = [NSMutableString stringWithString:[self URLDecodedString:urlNeedDecode]];
        //3.替换里面的默认Scheme为自己的Scheme
        NSString *afterHandleStr = [afterDecodeStr stringByReplacingOccurrencesOfString:@"alipays" withString:@"cynapp"];
        //4.然后把处理后的，和最开始切割的做下拼接，就得到了最终的字符串
        NSString *finalStr = [NSString stringWithFormat:@"%@?%@",urlBaseStr, [self  URLEncodeString:afterHandleStr]];
        
        //打开APP
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            //区分版本打开应用并传参
            if([[UIApplication sharedApplication] respondsToSelector:@selector(openURL:options:completionHandler:)]) {
                if (@available(iOS 10.0, *)) {
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:finalStr] options:@{UIApplicationOpenURLOptionUniversalLinksOnly: @NO} completionHandler:^(BOOL success) {
                        
                    }];
                } else {
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:finalStr]];
                }
            }
            else{
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:finalStr]];
            }
        });
        
        //5、WKWebview不再加载此url，交给App处理
        actionPolicy = WKNavigationActionPolicyCancel;
    }
    
    //执行是否加载WKWebview是否加载URL，不加会异常
    decisionHandler(actionPolicy);
}
    

- (void)webView:(WKWebView *)webView didFailNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error
{
    NSLog(@"加载失败:%@", error);
}


#pragma mark - WKUIDelegate

// 网页中有target="_blank" 在新窗口打开链接时，需要实现该代理方法，否则点击无反应，不会跳转
- (WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures
{
    if (navigationAction.targetFrame == nil || !navigationAction.targetFrame.isMainFrame) {
        [webView loadRequest:navigationAction.request];
    }
    return nil;
}


#pragma mark - private
#pragma mark -

// 编码
-  (NSString *)URLEncodeString:(NSString *)str
{
    NSString *encodedString = (NSString *)CFBridgingRelease((__bridge CFTypeRef _Nullable)[[str description] stringByAddingPercentEncodingWithAllowedCharacters: [[NSCharacterSet characterSetWithCharactersInString:@"!*'();:@&=+$,/?%#[]"] invertedSet]] );
    
//    NSString *encodedString = (NSString *)
//    CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
//                                                              (CFStringRef)unencodedString,
//                                                              NULL,
//                                                              (CFStringRef)@"!*'();:@&=+$,/?%#[]",
//                                                              kCFStringEncodingUTF8));
    return encodedString;
}

// 解码
- (NSString*)URLDecodedString:(NSString *)str
{
    NSString *decodedString = (NSString *)CFBridgingRelease(CFURLCreateStringByReplacingPercentEscapes(kCFAllocatorDefault, (CFStringRef)str, CFSTR("")));
    
//    NSString *decodedString = (__bridge_transfer NSString *)CFURLCreateStringByReplacingPercentEscapesUsingEncoding(NULL, (__bridge CFStringRef)str, CFSTR(""), CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
    return decodedString;
}



#pragma mark -
#pragma mark - getter

- (WKWebView *)webview
{
    if (!_webview) {
        WKWebViewConfiguration *webConfiguration = [WKWebViewConfiguration new];
        _webview = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:webConfiguration];
        _webview.UIDelegate = self;
        _webview.navigationDelegate = self;
        if (@available(iOS 11.0, *)) {
            _webview.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight - kBottomSafeAreaHeight);
        }
        
        _webview.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    return _webview;
}


@end
