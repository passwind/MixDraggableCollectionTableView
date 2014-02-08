//
//  QCMixViewHelper.h
//  TestMKEdit
//
//  Created by Zhu Yu on 14-2-7.
//  Copyright (c) 2014年 qcsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QCMixViewHelper : NSObject<UIGestureRecognizerDelegate>

-(id)initWithTableView:(UITableView*)tableView;

@property (nonatomic,readonly) UITableView * tableView;
@property (nonatomic, readonly) UIGestureRecognizer *longPressGestureRecognizer;
@property (nonatomic, readonly) UIGestureRecognizer *panPressGestureRecognizer;
@property (nonatomic, assign) UIEdgeInsets scrollingEdgeInsets;
@property (nonatomic, assign) CGFloat scrollingSpeed;
@property (nonatomic, assign) BOOL enabled;

@end
