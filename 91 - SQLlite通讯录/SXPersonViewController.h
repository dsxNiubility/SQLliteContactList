//
//  SXPersonViewController.h
//  91 - SQLlite通讯录
//
//  Created by 董 尚先 on 15/2/15.
//  Copyright (c) 2015年 shangxianDante. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PersonViewDelegate <NSObject>

- (void)addPersonShouldRelodata;

@end

@interface SXPersonViewController : UITableViewController

@property (nonatomic,weak) id<PersonViewDelegate> delegate;

@end
