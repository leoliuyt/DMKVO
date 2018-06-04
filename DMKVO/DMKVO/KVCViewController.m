//
//  KVCViewController.m
//  DMKVO
//
//  Created by lbq on 2018/6/4.
//  Copyright © 2018年 SC. All rights reserved.
//

#import "KVCViewController.h"
#import "DMObjectKVC.h"
#import "NSObject+DMKVC.h"

@interface KVCViewController ()

@property (nonatomic, strong) DMObjectKVC *objectKVC;

@end

@implementation KVCViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.objectKVC = [DMObjectKVC new];
    [self.objectKVC setValue:@"setleoliu" forKey:@"name"];
    // 类中定义字段名 | valueForKey中传入的key的名称
    // name -> name
    // _name -> name 或 _name
    // isName -> name 或 isName
    // _isName -> name 或 _isName 或 isName
    NSLog(@"name = %@",[self.objectKVC valueForKey:@"name"]);
    
//    NSLog(@"_name = %@",[self.objectKVC valueForKey:@"_name"]);
//    NSLog(@"isName = %@",[self.objectKVC valueForKey:@"isName"]);
//    NSLog(@"_isName = %@",[self.objectKVC valueForKey:@"_isName"]);
//    NSLog(@"name = %@",[self.objectKVC valueForKey:@"_isName"]);
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
