//
//  SXMainViewController.m
//  91 - SQLlite通讯录
//
//  Created by 董 尚先 on 15/2/15.
//  Copyright (c) 2015年 shangxianDante. All rights reserved.
//

#import "SXMainViewController.h"
#import "SXPersonViewController.h"
#import "SXDBTools.h"
@interface SXMainViewController ()<PersonViewDelegate,UISearchBarDelegate>

@property(nonatomic,strong) NSArray *persons;

@end

@implementation SXMainViewController
- (IBAction)btnAddPerson:(id)sender {
}

#pragma mark - ******************** 首次加载
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadPersons:nil];
    
    [self.tableView reloadData];
    
}

//- (void)viewDidAppear:(BOOL)animated
//{
//    [self loadPersons];
//    
//    [self.tableView reloadData];
//}

#pragma mark - ******************** 加载人物列表信息
- (void)loadPersons:(NSString *)searchText
{
    [[SXDBTools sharedDB].queue inDatabase:^(FMDatabase *db) {
        
        // 拼接查询字段 也可以更简单
        NSString *first = @"SELECT p.personName,c.companyName FROM T_Person p LEFT JOIN T_Company c ON c.companyId = p.companyId";
        
        if (searchText.length) {
             NSString *str = [NSString stringWithFormat:@"'%%%@%%'",searchText];
            NSString *second = [NSString stringWithFormat:@" WHERE p.personName LIKE %@ OR c.companyName LIKE %@",str,str];
            first = [first stringByAppendingString:second];
        }
       
        NSString *third = @" ORDER BY p.personName";
        
        first = [first stringByAppendingString:third];
//        NSLog(@"%@",first);
        FMResultSet *rs = [db executeQuery:first];
        // $$$$$
        NSMutableArray *array = [NSMutableArray array];
        while ([rs next]) {
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            NSString *personName = [rs stringForColumn:@"personName"];
            NSString *companyName = [rs stringForColumn:@"companyName"];
            if (companyName.length == 0) {
                companyName = @"";
            }
            
            [dict setObject:personName forKey:@"personName"];
            [dict setObject:companyName forKey:@"companyName"];
            
            
            [array addObject:dict];
        }
        self.persons = array;
    }];
}

#pragma mark - ******************** 数据源方法
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.persons.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ID = @"PersonCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    }
    cell.textLabel.text = self.persons[indexPath.row][@"personName"];
    cell.detailTextLabel.text = self.persons[indexPath.row][@"companyName"];
    return cell;
}

#pragma mark - ******************** 即将跳转
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    SXPersonViewController *pvc = segue.destinationViewController;
    pvc.delegate = self;
}

#pragma mark - ******************** 代理方法可以刷新
- (void)addPersonShouldRelodata
{
    [self loadPersons:nil];
    [self.tableView reloadData];
}

#pragma mark - ******************** searchBar代理方法
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [self loadPersons:searchText];
    [self.tableView reloadData];
}
@end
