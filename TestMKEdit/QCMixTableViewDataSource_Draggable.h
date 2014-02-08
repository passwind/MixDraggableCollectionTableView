//
//  QCMixTableViewDataSource_Draggable.h
//  TestMKEdit
//
//  Created by Zhu Yu on 14-2-7.
//  Copyright (c) 2014年 qcsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@class QCMixViewHelper;

@protocol QCMixTableViewDataSource_Draggable <UITableViewDataSource>
@required

- (void)qcMixTableView:(UITableView *)tableView moveItemAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath;
- (BOOL)qcMixTableView:(UITableView *)tableView canMoveItemAtIndexPath:(NSIndexPath *)indexPath;

@optional

- (BOOL)qcMixTableView:(UITableView *)tableView canMoveItemAtIndexPath:(NSIndexPath *)indexPath toIndexPath:(NSIndexPath *)toIndexPath;

@end
