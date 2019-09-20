//
//  CacheWebviewController.m
//  QianDaoDemo
//
//  Created by gaojianlong on 2019/8/12.
//  Copyright © 2019 gaojianlong. All rights reserved.
//

#import "CacheWebviewController.h"
#import "NSURLProtocolCustom.h"

@interface CacheWebviewController () <UIWebViewDelegate>

@property (nonatomic, strong) UIWebView *webview;

@end

@implementation CacheWebviewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"远程H5加载本地资源";
    [self.view addSubview:self.webview];
    [self loadRequest];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.webview.frame = self.view.bounds;
}

- (void)loadRequest
{
    // 这里可以看出 只要注册一次就够了。。。我们可以将它写在delegate 入口就可以实现所有的请求拦截
    [NSURLProtocol registerClass:[NSURLProtocolCustom class]];
    
    NSURL *url = [NSURL URLWithString:[[NSBundle mainBundle] pathForResource:@"index" ofType:@"html" inDirectory:@"GuidePageSource"]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.webview loadRequest:request];
}

#pragma mark -
#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSURL *url = [request URL];
    if ([[url scheme] isEqualToString:@"gohome"]) {
        NSLog(@"---去首页---");
        return NO;
    }
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSLog(@"webview load error: %@", error);
}

#pragma mark -
#pragma mark - 懒加载

- (UIWebView *)webview
{
    if (!_webview) {
        _webview = [[UIWebView alloc] init];
        _webview.backgroundColor = [UIColor whiteColor];
        _webview.delegate = self;
    }
    return _webview;
}


@end
