//
//  ViewController.m
//  webkit
//
//  Created by msbaby on 2019/1/16.
//  Copyright © 2019 msbaby. All rights reserved.
//  JS调用OCdemo

#import "JSOCDemoVC.h"
#import <WebKit/WebKit.h>
#import "JKEventHandler.h"
@interface JSOCDemoVC ()<WKNavigationDelegate,WKUIDelegate>
@property(nonatomic,strong) WKWebView *webView;
@property (nonatomic,strong) JKEventHandler *eventHandler;
@end

@implementation JSOCDemoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *path = [[NSBundle mainBundle] bundlePath];
    
    NSURL *baseURL = [NSURL fileURLWithPath:path];
    
    NSString * htmlPath = [[NSBundle mainBundle] pathForResource:@"test"
                                                          ofType:@"html"];
    
    NSString * htmlCont = [NSString stringWithContentsOfFile:htmlPath
                                                    encoding:NSUTF8StringEncoding
                                                       error:nil];
    
    [self.webView loadHTMLString:htmlCont baseURL:baseURL];
}

- (void)viewWillAppear:(BOOL)animated{

    [super viewWillAppear:animated];

    self.navigationController.navigationBarHidden = YES;

    /*! @abstract Adds a script message handler.
     @param scriptMessageHandler The message handler to add.
     @param name The name of the message handler.
     @discussion Adding a scriptMessageHandler adds a function
     window.webkit.messageHandlers.<name>.postMessage(<messageBody>) for all
     frames.
     */
#warning msbaby - 添加脚本处理程序 注意遵循WKScriptMessageHandler协议
  //  [self.webView.configuration.userContentController addScriptMessageHandler:self name:@"backClick"];
    
}
////- (void)viewWillDisappear:(BOOL)animated{
//
//    [super viewWillAppear:animated];
//
//    self.navigationController.navigationBarHidden = NO;
//
//#warning 注意：addScriptMessageHandler很容易引起循环引用，导致控制器无法被释放，所以必须在vc销毁前把它移除
//    [self.webView.configuration.userContentController removeScriptMessageHandlerForName:@"backClick"];
//}
//- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message{
//
//#warning 两个主要参数 message.name:JS那边的方法名  message.body:JS传过来的参数 为id类型 NSArray,NSDictionary,NSString等等
//
//    if ([message.name isEqualToString:@"backClick"]) {
//
//        [self.navigationController popViewControllerAnimated:YES];
//
//    }
//}

- (WKWebView *)webView{
    
    if (_webView == nil) {
        
        
        self.eventHandler = [JKEventHandler customInitWithHandlerDelegate:self];
           WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
           // 设置偏好设置
           config.preferences = [[WKPreferences alloc] init];
           // 默认为0
         //  config.preferences.minimumFontSize = 10;
           // 默认认为YES
           config.preferences.javaScriptEnabled = YES;
           // 在iOS上默认为NO，表示不能自动通过窗口打开
           config.preferences.javaScriptCanOpenWindowsAutomatically = YES;
           
           
           // web内容处理池
           config.processPool = [[WKProcessPool alloc] init];
           
           
           WKUserScript *usrScript = [[WKUserScript alloc] initWithSource:[JKEventHandler handlerJS] injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
           
           // 通过JS与webview内容交互
           config.userContentController = [[WKUserContentController alloc] init];
           
           [config.userContentController addUserScript:usrScript];
           // 注入JS对象名称AppModel，当JS通过AppModel来调用时，
           // 我们可以在WKScriptMessageHandler代理中接收到
           [config.userContentController addScriptMessageHandler:self.eventHandler  name:JKEventHandlerName];
      
        _webView = [[WKWebView alloc] initWithFrame:self.view.frame configuration:config];
        
        _webView.navigationDelegate = self;
        self.eventHandler.webView = _webView;
        //self.eventHandler.hodlerInstance= self;
        //self.eventHandler.hodlerClassName= NSStringFromClass([JSOCDemoVC class])  ;
         _webView.UIDelegate = self;
        [self.view addSubview:_webView];
        
    }
    return _webView;
}


// 在JS端调用alert函数时，会触发此代理方法。
// JS端调用alert时所传的数据可以通过message拿到
// 在原生得到结果后，需要回调JS，是通过completionHandler回调
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message
initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler {
    NSLog(@"100===%s", __FUNCTION__);
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"alert" message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:
                      UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                          completionHandler();
                      }]];
    
    [self presentViewController:alert animated:YES completion:NULL];
    NSLog(@"%@", message);
}

// JS端调用confirm函数时，会触发此方法
// 通过message可以拿到JS端所传的数据
// 在iOS端显示原生alert得到YES/NO后
// 通过completionHandler回调给JS端
- (void)webView:(WKWebView *)webView
runJavaScriptConfirmPanelWithMessage:(NSString *)message
initiatedByFrame:(WKFrameInfo *)frame
completionHandler:(void (^)(BOOL result))completionHandler {
    NSLog(@"101===%s", __FUNCTION__);
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:
                                @"confirm" message:@"JS调用confirm"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定"
                                              style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action){
                                                  completionHandler(YES);
                                              }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消"
                                              style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                                                  completionHandler(NO);
                                              }]];
    [self presentViewController:alert animated:YES completion:NULL];
    NSLog(@"%@", message);
}

// JS端调用prompt函数时，会触发此方法
// 要求输入一段文本
// 在原生输入得到文本内容后，通过completionHandler回调给JS
- (void)webView:(WKWebView *)webView
runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt
    defaultText:(nullable NSString *)defaultText
initiatedByFrame:(WKFrameInfo *)frame
completionHandler:(void (^)(NSString * __nullable result))completionHandler {
    NSLog(@"102===%s", __FUNCTION__);
    NSLog(@"%@", prompt);
   
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:
                                    prompt message:defaultText
                                                                preferredStyle:UIAlertControllerStyleAlert];
        [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.textColor = [UIColor redColor];
        }];
        [alert addAction:[UIAlertAction actionWithTitle:@"确定"
                                                  style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                                                      completionHandler([[alert.textFields lastObject] text]);
                                                  }]];
        
        [self presentViewController:alert animated:YES completion:NULL];
        
    
    
    
}


- (void)getNativeInfo:(NSDictionary *)params :(void(^)(id response))successCallBack :(void(^)(id response))failureCallBack{
    NSLog(@"getNativeInfo %@",params);
    if (successCallBack) {
        successCallBack(@"succes111522");
    }
    
    if (failureCallBack) {
        failureCallBack(@"failure !!!24324");
    }
}
-(void)dealloc{
    [self.eventHandler cleanHandler];
}
@end
