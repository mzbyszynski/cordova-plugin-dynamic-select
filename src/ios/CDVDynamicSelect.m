/*
The MIT License (MIT)

Copyright (c) 2014 Marc Zbyszynski

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
 */

#import "CDVDynamicSelect.h"
#import <objc/message.h>
#import "UIWebSelectingSinglePickerProxy.h"

@implementation CDVDynamicSelect

static IMP originalSelectMethodImp;
static CDVDynamicSelect* weakSelf;

#pragma mark - CDVPlugin
- (void)pluginInitialize {
    weakSelf = self;
}

-(void)refresh:(CDVInvokedUrlCommand *)command {
    UIPickerView* picker = [self getPicker:self.webView];
    // assure that there is picker input
    if (picker == nil) {
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"No Picker"];
         [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        return;
    }
    //TODO: should cache this?
    UIWebSelectingSinglePickerProxy* pickerProxy = [[UIWebSelectingSinglePickerProxy alloc] initWithPicker:picker];
    [pickerProxy refreshOptions];
}

-(void)enableOptionFocusChangeEvents:(CDVInvokedUrlCommand *)command {
    if (!originalSelectMethodImp) {
        NSLog(@"swizzlin");
        UIPickerView* picker = [self getPicker:self.webView];
        if (picker == nil) {
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"No Picker"];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
            return;
        }
        Method m = class_getInstanceMethod([picker class], @selector(pickerView:didSelectRow:inComponent:));
        originalSelectMethodImp = method_setImplementation(m, (IMP)_didSelectRowReplacementMethod);
    } else {
        NSLog(@"optionfocuschangeevents already enabled");
    }
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

// Retrieves the |UIPickerView| that is being used by the |UIWebView| by recursively walking through it's subviews.
-(UIPickerView*) getPicker:(UIView*)view {
    UIPickerView* out = nil;
    for (UIView *vs in view.subviews) {
        if ([vs inputView]) {
            UIView *input = [vs inputView];
            if ([input isKindOfClass: [UIPickerView class]]) {
                return (UIPickerView*)input;
            }
        }
        out = [self getPicker:vs];
        if (out != nil) {
            return out;
        }
    }
    return out;
}

void _didSelectRowReplacementMethod(id self, SEL _cmd, UIPickerView* pickerView, NSInteger row, NSInteger component) {
    NSLog(@"my didSelectRow method was invoked!");
    ((void(*)(id, SEL, UIPickerView*, NSInteger, NSInteger))originalSelectMethodImp)(self, _cmd, pickerView, row, component);
    [weakSelf.commandDelegate evalJs:[NSString stringWithFormat:@"cordova.plugins.DynamicSelect.notifySelectFocusChange(%ld);", row]];
}

@end
