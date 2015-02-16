//
//  SXPersonViewController.m
//  91 - SQLlite通讯录
//
//  Created by 董 尚先 on 15/2/15.
//  Copyright (c) 2015年 shangxianDante. All rights reserved.
//

#import "SXPersonViewController.h"
#import "SXDBTools.h"

@interface SXPersonViewController ()<UIPickerViewDelegate,UIPickerViewDataSource,UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UITextField *nameText;
@property (weak, nonatomic) IBOutlet UITextField *phoneText;
@property (weak, nonatomic) IBOutlet UITextField *ageText;
@property (weak, nonatomic) IBOutlet UITextField *companyText;


@property (nonatomic, strong) UIPickerView *pickerView;

/** 存放公司 */
@property (nonatomic, strong) NSArray *companies;

@end

@implementation SXPersonViewController

#pragma mark - ******************** 懒加载
- (UIPickerView *)pickerView
{
    if (_pickerView == nil) {
        _pickerView = [[UIPickerView alloc]init];
        _pickerView.delegate = self;
        _pickerView.dataSource = self;
    }
    return _pickerView;
}

#pragma mark - ******************** 首次加载
- (void)viewDidLoad {
    [super viewDidLoad];
    self.companyText.inputView = self.pickerView;
    
    [self loadCompanies];
    
}


#pragma mark - ******************** 添加公司按钮
- (IBAction)btnAddCompany:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"添加公司" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    
    [alert show];
}



#pragma mark - ******************** 弹窗之后点击保存
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        NSLog(@"点击了取消");
    }else{
        NSLog(@"点击了确定");
        UITextField *textFiled = [alertView textFieldAtIndex:0];
        if (textFiled.text.length == 0) return;
        
        // 保存数据
        [[SXDBTools sharedDB].queue inDatabase:^(FMDatabase *db) {
            // $$$$$ 这里必须是update
            [db executeUpdate:@"INSERT INTO T_Company (companyName) VALUES (?)",textFiled.text];
            NSLog(@"保存成功");
            
            // 重新加载并且更新
            FMResultSet *rs = [db executeQuery:@"select companyID,companyName from T_Company"];
            
            NSMutableArray *array = [NSMutableArray array];
            while ([rs next]) {
                NSMutableDictionary *dict = [NSMutableDictionary dictionary];
                NSInteger companyIndex = [rs intForColumn:@"companyID"];
                NSString *companyName = [rs stringForColumn:@"companyName"];
                
                [dict setObject:@(companyIndex) forKey:@"companyID"];
                [dict setObject:companyName forKey:@"companyName"];
                
                
                [array addObject:dict];
            }
            self.companies = array;
            [self.pickerView  reloadAllComponents];
        }];
    }
}

#pragma mark - ******************** pickerView的一系列方法
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return self.companies.count;
}
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return self.companies[row][@"companyName"];
}
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    // 记录选中的companyId
    self.companyText.tag = [self.companies[row][@"companyID"] intValue]; // $$$$$
    self.companyText.text = self.companies[row][@"companyName"];
}

#pragma mark - ******************** 加载公司信息
- (void)loadCompanies
{
    [[SXDBTools sharedDB].queue inDatabase:^(FMDatabase *db) {  // $$$$$ 看好是Database
        
        // 重新加载并且更新
        FMResultSet *rs = [db executeQuery:@"select companyID,companyName from T_Company"];
        
        NSMutableArray *array = [NSMutableArray array];
        while ([rs next]) {
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            NSInteger companyIndex = [rs intForColumn:@"companyID"];
            NSString *companyName = [rs stringForColumn:@"companyName"];
            
            [dict setObject:@(companyIndex) forKey:@"companyID"];
            [dict setObject:companyName forKey:@"companyName"];
            
            
            [array addObject:dict];
        }
        self.companies = array;
        [self.pickerView  reloadAllComponents];
    }];
}

#pragma mark - ******************** 保存信息
- (IBAction)save {
    
    NSInteger companyID = self.companyText.tag;
    NSNumber *companyNum = nil;
    if (companyID > 0) {
        companyNum = @(companyID);
    }
     [[SXDBTools sharedDB].queue inDatabase:^(FMDatabase *db) {
         [db executeUpdate:@"INSERT INTO T_Person (companyId,personName,phoneNo,age) VALUES(?,?,?,?)",companyNum,self.nameText.text,self.phoneText.text,self.ageText.text];
         
         NSLog(@"保存数据成功");
     }];
    
    if ([self.delegate respondsToSelector:@selector(addPersonShouldRelodata)]) {
        [self.delegate addPersonShouldRelodata];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

@end
