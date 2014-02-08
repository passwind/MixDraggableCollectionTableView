//
//  UITableView+Draggable.m
//  TestMKEdit
//
//  Created by Zhu Yu on 14-2-7.
//  Copyright (c) 2014年 qcsoft. All rights reserved.
//

#import "UITableView+Draggable.h"
#import "QCMixViewHelper.h"
#import <objc/runtime.h>

@implementation UITableView (Draggable)

-(QCMixViewHelper*)getHelper
{
    QCMixViewHelper * helper=objc_getAssociatedObject(self, "QCMixViewHelper");
    if (helper==nil) {
        helper=[[QCMixViewHelper alloc] initWithTableView:self];
        objc_setAssociatedObject(self, "QCMixViewHelper", helper, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return helper;
}

- (BOOL)draggable
{
    return [self getHelper].enabled;
}

- (void)setDraggable:(BOOL)draggable
{
    [self getHelper].enabled = draggable;
}

- (UIEdgeInsets)scrollingEdgeInsets
{
    return [self getHelper].scrollingEdgeInsets;
}

- (void)setScrollingEdgeInsets:(UIEdgeInsets)scrollingEdgeInsets
{
    [self getHelper].scrollingEdgeInsets = scrollingEdgeInsets;
}

- (CGFloat)scrollingSpeed
{
    return [self getHelper].scrollingSpeed;
}

- (void)setScrollingSpeed:(CGFloat)scrollingSpeed
{
    [self getHelper].scrollingSpeed = scrollingSpeed;
}
@end
