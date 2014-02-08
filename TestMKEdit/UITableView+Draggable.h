//
//  UITableView+Draggable.h
//  TestMKEdit
//
//  Created by Zhu Yu on 14-2-7.
//  Copyright (c) 2014年 qcsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QCMixTableViewDataSource_Draggable.h"

@interface UITableView (Draggable)

@property (nonatomic, assign) BOOL draggable;
@property (nonatomic, assign) UIEdgeInsets scrollingEdgeInsets;
@property (nonatomic, assign) CGFloat scrollingSpeed;

@end
