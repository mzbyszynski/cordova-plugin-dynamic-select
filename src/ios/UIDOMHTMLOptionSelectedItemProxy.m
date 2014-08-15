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

#import "UIDOMHTMLOptionSelectedItemProxy.h"
#import <objc/message.h>

@implementation UIDOMHTMLOptionSelectedItemProxy

@synthesize item = _item;

static Class selectedItemClass;
static Method initSelectedItemMethod;
static Method setSelectedMethod;

-(id)initWithHTMLOptionNode:(id)optionNode {
    self = [super init];
    if (!selectedItemClass) {
        selectedItemClass = NSClassFromString(@"UIDOMHTMLOptionSelectedItem");
    }
    if (!initSelectedItemMethod) {
        SEL initMethodSel = NSSelectorFromString(@"initWithHTMLOptionNode:");
        initSelectedItemMethod = class_getInstanceMethod(selectedItemClass, initMethodSel);
    }
    _item = [selectedItemClass alloc];
    _item = method_invoke(_item, initSelectedItemMethod, optionNode);
    return self;
}

-(void)setSelected:(BOOL)selected {
    if (!setSelectedMethod) {
        SEL setSelectedSel = NSSelectorFromString(@"setSelected:");
        setSelectedMethod = class_getInstanceMethod(selectedItemClass, setSelectedSel);
    }
    method_invoke(self.item, setSelectedMethod, selected);
}

@end
