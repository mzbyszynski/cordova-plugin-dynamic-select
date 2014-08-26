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

#import "UIWebSelectingSinglePickerProxy.h"
#import <objc/message.h>
#import "DOMHTMLOptionElementProxy.h"
#import "UIDOMHTMLOptionSelectedItemProxy.h"

@interface UIWebSelectingSinglePickerProxy()

@property (nonatomic, strong) UIPickerView *picker;

@end

@implementation UIWebSelectingSinglePickerProxy

static Method initMethod;

-(id)initWithPicker:(UIPickerView *)picker {
    self = [super init];
    self.picker = picker;
    return self;
}

-(NSInteger)indexToSelectWhenDone {
    id indexToSelectWhenDone = [self.picker valueForKey:@"_indexToSelectWhenDone"];
    return [indexToSelectWhenDone integerValue];
}

-(DOMHTMLSelectElementProxy *)selectNode {
    id sel = [self.picker valueForKey:@"_selectNode"];
    return [[DOMHTMLSelectElementProxy alloc] initWithSelectElement:sel];
}

-(void)refreshOptions {
    id indexToSelectWhenDone = [self.picker valueForKey:@"_indexToSelectWhenDone"];
    NSInteger focused = [indexToSelectWhenDone integerValue];

    DOMHTMLSelectElementProxy *select = [self selectNode];
    NSInteger selected = [select selectedIndex];
    NSMutableArray *newOpts = [NSMutableArray arrayWithCapacity:[select length]];
    DOMHTMLOptionsCollectionProxy *options = [select options];
    for (int i = 0; i < [select length]; i++) {
        DOMHTMLOptionElementProxy *opt = [options item:i];
        UIDOMHTMLOptionSelectedItemProxy *selItem = [[UIDOMHTMLOptionSelectedItemProxy alloc] initWithHTMLOptionNode:[opt optionEl]];
        // another bit of ugliness in this ugly business. When using this plugin with another js framework that is manipulating the
        // DOM and managing the state of the select associated with this picker, it can cause some memory errors if this code tries to
        // change the selection while it is already in a changed state. This comparision prevents that in the use cases that I have seen
        // so far.
        if (selected != focused) {
            if (i == focused) {
                NSLog(@"Setting item %d to selected",i);
                [selItem setSelected:YES];
            } else {
                [selItem setSelected:NO];
            }
        }
        [newOpts addObject:[selItem item]];
    }
    if (!initMethod) {
        SEL initSel = NSSelectorFromString(@"initWithDOMHTMLSelectElement:allItems:");
        initMethod = class_getInstanceMethod([self.picker class], initSel);
    }
    method_invoke(self.picker, initMethod, select.selectEl  , newOpts);
}




@end
