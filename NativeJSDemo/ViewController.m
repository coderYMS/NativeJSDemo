//
//  ViewController.m
//  NativeJSDemo
//
//  Created by kuailegongchang on 16/12/26.
//  Copyright © 2016年 kuailegongchang. All rights reserved.
//

#import "ViewController.h"
#import <JavaScriptCore/JavaScriptCore.h>

@protocol JSNativeDelegate <JSExport>

- (void)nativeLogMethod:(NSString *)jsonString;
- (void)nativeLogMethodWithTwoParam:(NSString *)stringOne anotherParam:(NSString *)stringTwo;
- (void)callBackMethod;

@end

@interface ViewController ()<UIWebViewDelegate,JSNativeDelegate>

@property (nonatomic,strong) UIWebView *webView;

@property (nonatomic,strong) JSContext *jsContext;

@end

@implementation ViewController

#pragma mark - lazy load
- (UIWebView *)webView {
    if (!_webView) {
        _webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
        _webView.delegate = self;
    }
    return _webView;
}

#pragma mark - life circle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self.view addSubview:self.webView];
    
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"native" ofType:@"html"]]]];

}

#pragma mark - UIWebViewDelegate
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    self.jsContext = [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    self.jsContext[@"MobileClass"] = self;
}

#pragma mark - JSNativeDelegate
- (void)nativeLogMethod:(NSString *)jsonString {
    NSDictionary *jsonDic = [self dictionFromString:jsonString];
    NSLog(@"native log %@",jsonDic);
    NSLog(@"thread is %@",[NSThread currentThread]);
}

- (void)nativeLogMethodWithTwoParam:(NSString *)stringOne anotherParam:(NSString *)stringTwo {
    NSLog(@"native log (%@·%@)",stringOne,stringTwo);
    NSLog(@"thread is %@",[NSThread currentThread]);
}

- (void)callBackMethod {
    
    //js调用的native方法，在子线程（假如是 thread 7）运行，如果回调js方法时，不在thread 7回调，会有问题。。。
//    dispatch_async(dispatch_get_main_queue(), ^{
//        NSLog(@"call native on main thread");
//        JSValue *jsCallBack = self.jsContext[@"jsMethod"];
//        [jsCallBack callWithArguments:@[@"FBI Warning"]];
//    });
    
    NSLog(@"thread is %@",[NSThread currentThread]);
    JSValue *jsCallBack = self.jsContext[@"jsMethod"];
    [jsCallBack callWithArguments:@[@"FBI Warning"]];
}

#pragma mark - private method
- (NSDictionary *)dictionFromString:(NSString *)dicString {
    if (!dicString) {
        return nil;
    }
    NSData *data = [dicString dataUsingEncoding:NSUTF8StringEncoding];
    if (!data) {
        return nil;
    }
    id object = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    return object;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
