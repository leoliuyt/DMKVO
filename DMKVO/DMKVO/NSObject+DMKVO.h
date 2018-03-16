//
//  NSObject+DMKVO.h
//  DMKVO
//
//  Created by leoliu on 2018/3/15.
//  Copyright © 2018年 SC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (DMKVO)
- (void)dm_addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(nullable void *)context;
@end
