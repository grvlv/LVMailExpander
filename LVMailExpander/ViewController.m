//
//  ViewController.m
//  LVMailExpander
//
//  Created by GRV on 2018/12/10.
//  Copyright © 2018 GRV. All rights reserved.
//

#import "ViewController.h"
#import <WebKit/WebKit.h>

@interface ViewController () <WKScriptMessageHandler>

@property (nonatomic) BOOL isShowQuote;
@property (nonatomic, strong) NSString *htmlStr;
@property (nonatomic, strong) WKWebView *webView;

@end

@implementation ViewController

- (void)dealloc {
    [_webView.configuration.userContentController removeScriptMessageHandlerForName:@"quoteAction"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _htmlStr = @"<html><head><meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, user-scalable=no\"><meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\"><style type=\"text/css\"><!--p.p1{margin:0.0px 0.0px 0.0px 0.0px;font:16.0px 'PingFang SC';color:#000000}span.s1{font-family:'PingFangSC-Regular';font-weight:normal;font-style:normal;font-size:16.00px}--></style></head><body><p dir=\"ltr\">转发邮件</p><br /><div class=\"blockquote_fromhere_element\"></div><font face=\"Tahoma\" size=\"2\"><b>发件人:</b> GRV_Lv<br /><b>发送时间:</b> 2018年12月10日 8:38:20<br /><b>收件人:</b> 裴珠泫; 朴敏荷; 权珉阿<br /><b>主题:</b> 通告<br /></font><br /><div><p class=\"p1\"><span class=\"s1\">邮件内容</span></p></div></body></html>";
    
    [self setupQuoteDiv];
    _webView = [[WKWebView alloc] initWithFrame:UIScreen.mainScreen.bounds];
    [_webView loadHTMLString:_htmlStr baseURL:nil];
    [self.view addSubview:_webView];
    
    _webView.configuration.preferences.javaScriptEnabled = YES;
    [_webView.configuration.userContentController addScriptMessageHandler:self name:@"quoteAction"];
}

- (void)setupQuoteDiv {
    NSRange range = [_htmlStr rangeOfString:@"<div class=\"blockquote_fromhere_element\">" options:NSCaseInsensitiveSearch range:NSMakeRange(0, _htmlStr.length)];
    if (range.location == NSNotFound) {
        return;
    }
    _isShowQuote = YES;
    NSString *labelTag = [NSString stringWithFormat:@"<div><label class=\"quoteLabel\" style=\"font-size:14px;color:#888888;vertical-align:middle\" onclick=\"window.webkit.messageHandlers.quoteAction.postMessage(0)\">展开引用内容</label>"];
    UIImage *quoteArrow = [UIImage imageNamed:@"quoteArrow"];
    NSString *imageSource = [NSString stringWithFormat:@"data:image/jpg;base64,%@",[UIImageJPEGRepresentation(quoteArrow, 1) base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed]];
    NSString *imgTag = [NSString stringWithFormat:@"  <img class=\"quoteArrow\" src=\"%@\" style=\"transform:rotate(0deg);vertical-align:middle;margin-bottom:2px\" width=\"15\" height=\"15\" onclick=\"window.webkit.messageHandlers.quoteAction.postMessage(0)\"/></div><br>", imageSource];
    NSString *divTag = @"<div class=\"quoteDiv\" style=\"display:none\">";
    NSString *insertTag = [NSString stringWithFormat:@"%@%@%@", labelTag, imgTag, divTag];
    _htmlStr = [_htmlStr stringByReplacingCharactersInRange:NSMakeRange(range.location, 0) withString:insertTag];
    _htmlStr = [_htmlStr stringByReplacingOccurrencesOfString:@"</body>" withString:@"</div></body>"];
}

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    if ([message.name isEqualToString:@"quoteAction"]) {
        NSString *divJs = [NSString stringWithFormat:@"document.getElementsByClassName(\"quoteDiv\")[0].style.display=\"%@\"", _isShowQuote ? @"block" : @"none"];
        NSString *labelJs = [NSString stringWithFormat:@"document.getElementsByClassName(\"quoteLabel\")[0].innerHTML=\"%@\"", _isShowQuote ? @"收起引用内容" : @"展开引用内容"];
        NSString *imgJs = [NSString stringWithFormat:@"document.getElementsByClassName(\"quoteArrow\")[0].style.transform=\"%@\"", _isShowQuote ? @"rotate(180deg)" : @"rotate(0deg)"];
        [self quoteAction:divJs];
        [self quoteAction:labelJs];
        [self quoteAction:imgJs];
        _isShowQuote = !_isShowQuote;
    }
}

- (void)quoteAction:(NSString *)js {
    [_webView evaluateJavaScript:js completionHandler:nil];
}

@end
