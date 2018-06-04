//
//  DMObjectKVC.m
//  DMKVO
//
//  Created by lbq on 2018/6/4.
//  Copyright © 2018年 SC. All rights reserved.
//

#import "DMObjectKVC.h"
@interface DMObjectKVC()
{
//    NSString *name;
//    NSString *_name;
//    NSString *isName;
//    NSString *_isName;
}
@end
@implementation DMObjectKVC

- (instancetype)init
{
    self = [super init];
//    name = @"leoliu";
//    _name = @"leoliu";
//    isName = @"leoliu";
//    _isName = @"leoliu";
    return self;
}

//- (void)setName:(NSString *)aName
//{
//    name = aName;
//}
//
//- (void)setIsName:(NSString *)aName
//{
//    name = aName;
//}

- (NSString *)isName {
    return @"isName";
}
- (NSString *)name {
    return @"name";
}
- (NSString *)getName
{
    return @"getName";
}




@end
