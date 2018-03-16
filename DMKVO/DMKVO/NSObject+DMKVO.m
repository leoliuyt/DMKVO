//
//  NSObject+DMKVO.m
//  DMKVO
//
//  Created by leoliu on 2018/3/15.
//  Copyright © 2018年 SC. All rights reserved.
//

#import "NSObject+DMKVO.h"
#import <objc/message.h>

NSString *const kDMKVONotifying = @"DMKVONotifying_";
NSString *const ObserverKey = @"ObserverKey";
NSString *const KeyPath = @"KeyPath";

@implementation NSObject (DMKVO)

- (void)dm_addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(nullable void *)context
{
    objc_setAssociatedObject(self, (__bridge const void * _Nonnull)(ObserverKey), observer, OBJC_ASSOCIATION_RETAIN);
    objc_setAssociatedObject(self, (__bridge const void * _Nonnull)(KeyPath), keyPath, OBJC_ASSOCIATION_RETAIN);
    //1、检查对象的类有没有相应的setter方法。
    NSString *methodName = setterName(keyPath);
    SEL setterSeloctor = NSSelectorFromString(methodName);
    Method setterMethod = class_getInstanceMethod([self class], setterSeloctor);
    if (!setterMethod) {
        NSLog(@"不存在keypath对应的setter方法");
        return;
    }
    
    //2、检查对象 isa 指向的类是不是一个 KVO 类。如果不是，新建一个继承原来类的子类，并把 isa 指向这个新建的子类；
    Class metalCls = object_getClass(self);
    NSString *strCls = NSStringFromClass(metalCls);
    if (![strCls hasPrefix:kDMKVONotifying]) {
        NSString *subClass = NSStringFromClass(self.class);
        metalCls = [self createClassWithClassName:subClass];
        
        //修改对象isa指针
        object_setClass(self, metalCls);
    }
    
    //3、检查对象的 KVO 类重写过没有这个 setter 方法。如果没有，添加重写的 setter 方法；
    if (![self hasSelector:setterSeloctor]) {
        const char *types = method_getTypeEncoding(setterMethod);
        class_addMethod(metalCls,
                        setterSeloctor,
                        (IMP)kvo_setter,
                        types);
    }
    //4、添加这个观察者
    
}

- (Class)createClassWithClassName:(NSString *)className
{
    //动态创建类
    NSString *kvoClassName = [kDMKVONotifying stringByAppendingString:className];
    Class cl = NSClassFromString(kvoClassName);
    if (cl) {
        return cl;
    }
    Class originalClass = object_getClass(self);
    Class kvoClass = objc_allocateClassPair(originalClass, kvoClassName.UTF8String, 0);
    Method clazzMethod = class_getInstanceMethod(originalClass, @selector(class));
    const char *types = method_getTypeEncoding(clazzMethod);
    class_addMethod(kvoClass, @selector(class), (IMP)kvo_class, types);
    
    objc_registerClassPair(kvoClass);
    return kvoClass;
}

- (void)setterImp:(id)sender
{
    id obsetver = objc_getAssociatedObject(self, (__bridge const void * _Nonnull)(ObserverKey));
    id keyPath = objc_getAssociatedObject(self, (__bridge const void * _Nonnull)(KeyPath));
//    NSDictionary<NSKeyValueChangeKey,id> *changeDict = oldName ? @{NSKeyValueChangeNewKey : sender, NSKeyValueChangeOldKey : sender} : @{NSKeyValueChangeNewKey : sender};
    [obsetver observeValueForKeyPath:keyPath ofObject:self change:nil context:nil];
}

//获取setter方法名

static NSString * setterName(NSString *key)
{
    if (key.length <= 0) {
        return nil;
    }
    NSString *methodName = [NSString stringWithFormat:@"set%@:",key.capitalizedString];
    return methodName;
}

static Class kvo_class(id self, SEL _cmd)
{
 NSLog(@"%@==%@",NSStringFromClass(object_getClass(self)),NSStringFromClass(class_getSuperclass(object_getClass(self))));
    return class_getSuperclass(object_getClass(self));
}

static void kvo_setter(id self, SEL _cmd, id newValue)
{
    NSString *setterName = NSStringFromSelector(_cmd);
    NSString *getterName = getterForSetter(setterName);
    
    if (!getterName) {
        NSString *reason = [NSString stringWithFormat:@"Object %@ does not have setter %@", self, setterName];
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:reason
                                     userInfo:nil];
        return;
    }
    
    id oldValue = [self valueForKey:getterName];
    
    struct objc_super superclazz = {
        .receiver = self,
        .super_class = class_getSuperclass(object_getClass(self))//Person
    };
    
    NSLog(@"%@",NSStringFromClass(class_getSuperclass(object_getClass(self))));
    // cast our pointer so the compiler won't complain
    void (*objc_msgSendSuperCasted)(void *, SEL, id) = (void *)objc_msgSendSuper;
    
    // call super's setter, which is original class's setter method
//    [self willChangeValueForKey:getterName];
    objc_msgSendSuperCasted(&superclazz, _cmd, newValue);
//    [self didChangeValueForKey:getterName];
    
    id observer = objc_getAssociatedObject(self, (__bridge const void * _Nonnull)(ObserverKey));
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    if (oldValue) {
        [dic setObject:oldValue forKey:NSKeyValueChangeOldKey];
    }
    if (newValue) {
        [dic setObject:newValue forKey:NSKeyValueChangeNewKey];
    }
    
    [observer observeValueForKeyPath:getterName ofObject:self change:[dic copy] context:nil];
//    // look up observers and call the blocks
//    NSMutableArray *observers = objc_getAssociatedObject(self, (__bridge const void *)(kPGKVOAssociatedObservers));
//    for (PGObservationInfo *each in observers) {
//        if ([each.key isEqualToString:getterName]) {
//            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//                each.block(self, getterName, oldValue, newValue);
//            });
//        }
//    }
}

- (BOOL)hasSelector:(SEL)selector
{
    Class class = object_getClass(self);
    unsigned int methodCount = 0;
    Method *methodList = class_copyMethodList(class, &methodCount);
    for (unsigned int i = 0; i < methodCount; i++) {
        SEL sel = method_getName(methodList[i]);
        if (sel == selector) {
            free(methodList);
            return YES;
        }
    }
    free(methodList);
    return NO;
}

static NSString * getterForSetter(NSString *setter)
{
    if (setter.length <=0 || ![setter hasPrefix:@"set"] || ![setter hasSuffix:@":"]) {
        return nil;
    }
    
    // remove 'set' at the begining and ':' at the end
    NSRange range = NSMakeRange(3, setter.length - 4);
    NSString *key = [setter substringWithRange:range];
    
    // lower case the first letter
    NSString *firstLetter = [[key substringToIndex:1] lowercaseString];
    key = [key stringByReplacingCharactersInRange:NSMakeRange(0, 1)
                                       withString:firstLetter];
    
    return key;
}

@end
