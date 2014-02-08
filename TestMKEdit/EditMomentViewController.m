//
//  EditMomentViewController.m
//  TestMKEdit
//
//  Created by Zhu Yu on 14-2-6.
//  Copyright (c) 2014年 qcsoft. All rights reserved.
//

#import "EditMomentViewController.h"
#import "EditMomentCell.h"
#import "Constants.h"

@interface EditMomentViewController ()<EditMomentCellDelegate>

@property (nonatomic,strong) NSMutableArray * moments;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation EditMomentViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	_moments=[@[] mutableCopy];
    
    NSMutableArray * array=[NSMutableArray arrayWithArray:@[@"IMG_0288.JPG",@"IMG_0300.JPG",@"test.jpg"]];
    [_moments addObject:array];
    
    NSMutableArray * array1=[NSMutableArray arrayWithArray:@[@"IMG_0363.JPG"]];
    [_moments addObject:array1];
    
    NSMutableArray * array2=[NSMutableArray arrayWithArray:@[@"IMG_0364.JPG"]];
    [_moments addObject:array2];
    
    [_tableView setEditing:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource method
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_moments count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleNone;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    EditMomentCell * cell=[tableView dequeueReusableCellWithIdentifier:@"EditMomentCell"];
    NSArray * array=[_moments objectAtIndex:indexPath.row];
    [cell setAssets:[NSMutableArray arrayWithArray:array]];
    cell.delegate=self;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    NSArray * array=_moments[fromIndexPath.row];
    
    [_moments removeObjectAtIndex:fromIndexPath.row];
    
    [_moments insertObject:array atIndex:toIndexPath.row];
}

#pragma mark - UITableViewDelegate method
- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray * array=_moments[indexPath.row];
    int rows=(int)ceil((double)([array count]+1)/3.0);
    CGFloat height=kTableCellPadding*2+rows*kCollectionViewCellHeight+(rows+1)*kCollectionViewPadding;
    return height;
}

#pragma mark - EditMomentCellDelegate method
-(void)editMomentCell:(EditMomentCell *)cell didAddAsset:(NSString *)image
{
    NSIndexPath * indexPath=[self.tableView indexPathForCell:cell];
    
    NSMutableArray * array=_moments[indexPath.row];
    [array addObject:image];
    [_moments replaceObjectAtIndex:indexPath.row withObject:array];
    
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
}

-(void)editMomentCell:(EditMomentCell *)cell didDeleteAsset:(NSString *)image
{
    NSIndexPath * indexPath=[self.tableView indexPathForCell:cell];
    
    NSMutableArray * array=_moments[indexPath.row];
    [array removeObject:image];
    [_moments replaceObjectAtIndex:indexPath.row withObject:array];
    
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark - QCMixTableViewDataSource_Draggable method
-(void)qcMixTableView:(UITableView *)tableView moveItemAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    if (fromIndexPath.section==toIndexPath.section) {
        NSMutableArray * assets=_moments[fromIndexPath.section];
        NSString * image=assets[fromIndexPath.item];
        [assets removeObjectAtIndex:fromIndexPath.item];
        [assets insertObject:image atIndex:toIndexPath.item];
        [_moments replaceObjectAtIndex:fromIndexPath.section withObject:assets];
    }
    else{
        NSMutableArray * assets=_moments[fromIndexPath.section];
        NSString * image=assets[fromIndexPath.item];
        [assets removeObjectAtIndex:fromIndexPath.item];
        [_moments replaceObjectAtIndex:fromIndexPath.section withObject:assets];
        
        assets=_moments[toIndexPath.section];
        [assets insertObject:image atIndex:toIndexPath.item];
        [_moments replaceObjectAtIndex:toIndexPath.section withObject:assets];
    }
    
    [_tableView reloadData];
}

-(BOOL)qcMixTableView:(UITableView *)tableView canMoveItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSIndexPath * tableIndex=[NSIndexPath indexPathForRow:indexPath.section inSection:0];
    EditMomentCell * cell=(EditMomentCell*)[self.tableView cellForRowAtIndexPath:tableIndex];
    UICollectionView * collectionView=cell.collectionView;
    if (indexPath.item==[collectionView numberOfItemsInSection:0]-1) {
        //AddAssetCell can't move
        return NO;
    }
    
    return YES;
}

- (BOOL)qcMixTableView:(UITableView *)tableView canMoveItemAtIndexPath:(NSIndexPath *)indexPath toIndexPath:(NSIndexPath *)toIndexPath
{
//    // Prevent item from being moved to index 
//    NSIndexPath * tableIndex=[NSIndexPath indexPathForRow:toIndexPath.section inSection:0];
//    EditMomentCell * cell=(EditMomentCell*)[self.tableView cellForRowAtIndexPath:tableIndex];
//    UICollectionView * collectionView=cell.collectionView;
//    if (toIndexPath.item==[collectionView numberOfItemsInSection:0]-1) {
//        return NO;
//    }

    return YES;
}

@end
