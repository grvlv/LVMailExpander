# LVMailExpander

在WebView中类似邮件转发内容展开收起功能，之前也有想过分为上下两部分控件来实现，但觉得最终要和Android统一实现方案，最后还是决定使用html和JS交互来完成这个功能点，通过约定的标识符来注入html标签，用JS交互来实现展开和收起的动作

# 关键点
```
<div class=\"blockquote_fromhere_element\"></div>
```
自定义的标识符，用来找到需要注入展开收起标签的位置

```
<label class=\"quoteLabel\" style=\"font-size:14px;color:#888888;vertical-align:middle\" onclick=\"window.webkit.messageHandlers.quoteAction.postMessage(0)\">展开引用内容</label>
```
文案标签，这边用class属性来作为标识符，之后会用JS通过class获取标签，修改文案内容，也可以是id或其他，最后影响的不过是JS获取方式

```
UIImage *quoteArrow = [UIImage imageNamed:@"quoteArrow"];
NSString *imageSource = [NSString stringWithFormat:@"data:image/jpg;base64,%@",[UIImageJPEGRepresentation(quoteArrow, 1)
NSString *imgTag = [NSString stringWithFormat:@"<img class=\"quoteArrow\" src=\"%@\" style=\"transform:rotate(0deg);vertical-align:middle;margin-bottom:2px\" width=\"15\" height=\"15\" onclick=\"window.webkit.messageHandlers.quoteAction.postMessage(0)\"/>", imageSource];
```
接下来是小箭头图标，在img标签里使用本地图片，scr需要使用base64格式，同label标签一样，注册点击事件

```
<div class=\"quoteDiv\" style=\"display:none\">
```
最后也是最关键的一步，生成一个div，嵌套下面需要隐藏的所有内容，之后通过JS调用，设置style的display属性来完成展开收起

# JS调用
```
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
```
WKWebView的JS回调，quoteAction是我们自定义的回调方法，新增了一个BOOL变量来控制文案和箭头的变化

# 最后
```
_webView.configuration.preferences.javaScriptEnabled = YES;
[_webView.configuration.userContentController addScriptMessageHandler:self name:@"quoteAction"];
[_webView.configuration.userContentController removeScriptMessageHandlerForName:@"quoteAction"];
```
最后别忘了开启WKWebView的JS调用，注册事件，记得退出界面前销毁，不然会造成内存泄漏
