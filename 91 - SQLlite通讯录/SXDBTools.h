//
//  SXDBTools.h
//  91 - SQLlite通讯录
//
//  Created by 董 尚先 on 15/2/15.
//  Copyright (c) 2015年 shangxianDante. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDB.h"
@interface SXDBTools : NSObject

/**
 *  数据库操作队列
 */
@property (nonatomic, strong) FMDatabaseQueue *queue;


+ (SXDBTools *)sharedDB;
@end
