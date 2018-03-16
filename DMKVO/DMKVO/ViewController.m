//
//  ViewController.m
//  DMKVO
//
//  Created by leoliu on 2018/3/15.
//  Copyright © 2018年 SC. All rights reserved.
//

#import "ViewController.h"
#import <objc/runtime.h>
#import "NSObject+DMKVO.h"
#import "Person.h"

@interface ViewController ()

@property (nonatomic, strong) Person *person;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    [self addObserver:nil forKeyPath:nil options:nil context:nil];
    // Do any additional setup after loading the view, typically from a nib.
//    SEL resolveSel = @selector(setName:);
//    Method swizzledMethod = class_getInstanceMethod([self class], resolveSel);
//    NSString *str = [[NSString alloc] initWithCString:method_getTypeEncoding(swizzledMethod) encoding:NSUTF8StringEncoding];
//    NSLog(@"%s====%@",method_getTypeEncoding(swizzledMethod),str);
    //BOOL didAddMethod =
    //class_addMethod([self class],
    //                sel,
    //                method_getImplementation(swizzledMethod),
    //                method_getTypeEncoding(swizzledMethod));
    
    
    self.person = [Person new];
    [self.person dm_addObserver:self forKeyPath:@"name" options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew context:nil];
    
    
    self.person.name = @"leoliu";
//    NSLog(@"%s",object_getClass(self.person));
}

//- (void)setName:(NSString *)name
//{
//
//}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    NSLog(@"%s",__func__);
    NSLog(@"%@",self.person.name);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
