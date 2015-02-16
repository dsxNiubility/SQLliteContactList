//
//  SXDBTools.m
//  91 - SQLlite通讯录
//
//  Created by 董 尚先 on 15/2/15.
//  Copyright (c) 2015年 shangxianDante. All rights reserved.
//

#import "SXDBTools.h"

@implementation SXDBTools

+ (SXDBTools *)sharedDB
{
    static SXDBTools *_instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc]init];
    });
    return _instance;
}

- (instancetype)init
{
    if (self = [super init]) {
        
        NSString *filePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        filePath = [filePath stringByAppendingPathComponent:@"readme.db"];
        
        _queue = [[FMDatabaseQueue alloc]initWithPath:filePath]; // $$$$$ 这也能忘？
        
        [self createTables];
        
    }
    return self;
}

- (void)createTables
{
    [self.queue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        
        BOOL result = NO;
        
        // 创建个人表
        result = [db executeUpdate:@"CREATE TABLE IF NOT EXISTS T_Person ("
                  "personId integer PRIMARY KEY AUTOINCREMENT NOT NULL,"
                  "personName text,"
                  "age integer,"
                  "phoneNo text,"
                  "companyId integer,"
                  "FOREIGN KEY (companyId) REFERENCES T_Company (companyId) ON DELETE SET NULL"
                  ");"];
        
        if (!result) {
            NSLog(@"创建失败应该回滚");
            *rollback = YES;
            
            return ;
        }
        
        // 创建成功才能来到这里
        [db executeUpdate:@"CREATE TABLE IF NOT EXISTS T_Company ("
         "companyId integer PRIMARY KEY AUTOINCREMENT NOT NULL,"
         "companyName text"
         ");"];
        
        NSLog(@"数据创建完成");
    }];
}

@end
