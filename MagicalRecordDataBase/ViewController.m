//
//  ViewController.m
//  MagicalRecordDataBase
//
//  Created by 佐毅 on 16/3/13.
//  Copyright © 2016年 上海乐住信息技术有限公司. All rights reserved.
//

#import "ViewController.h"
#import <MagicalRecord/MagicalRecord.h>
#import "Person.h"
#import "Person+CoreDataProperties.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    // 获取上下文环境
    NSManagedObjectContext *defaultContext = [NSManagedObjectContext MR_defaultContext];
    
    // 在当前上下文环境中创建一个新的 Person 对象.
    Person *person  = [Person MR_createEntityInContext:defaultContext];
    person.firstName = @"firstname";
    person.lastName  = @"lastname";
    person.age       = @100;
    
    // 保存修改到当前上下文中.
    [defaultContext MR_saveToPersistentStoreAndWait];
    
    
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext){
        
        Person *localPerson = [person MR_inContext:localContext];
        localPerson.firstName = @"Yan";
        localPerson.lastName = @"Feng";
    }];
    NSArray *personArray = [Person MR_findAll];
    if (personArray.count>0) {
        for (Person *person in personArray) {
            NSLog(@"firstName:%@    lastName:%@    age:%@",person.firstName,person.lastName,person.age);
        }
    }
    
    
    NSLog(@"--------------------------------");
    
    
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext){
        
        Person *localPerson = [person MR_inContext:localContext];
        localPerson.firstName = @"Yan";
        localPerson.lastName = @"Feng";
    }  completion:^(BOOL success, NSError *error) {//这个完成的block,在主线程(队列)中调用,所以可以在此block里安全触发UI更新.
        
        NSArray * persons = [Person MR_findAll];
        
        [persons enumerateObjectsUsingBlock:^(Person * obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSLog(@"firstname: %@, lastname: %@\n", obj.firstName, obj.lastName);
        }];
        
    }];

    
    /*
     删除实体对象
     
     删除默认上下文中的实体对象:
     
     [myPerson MR_deleteEntity];
     删除指定上下文中的实体对象:
     
     [myPerson MR_deleteEntityInContext:otherContext];
     删除默认上下文中的所有实体:
     
     [Person MR_truncateAll];
     删除指定上下文中的所有实体:
     
     [Person MR_truncateAllInContext:otherContext];
     */
     // Do any additional setup after loading the view, typically from a nib.
}


- (void)magicaRecord{
    
    //创建上下文管理类
    for (NSInteger i = 0; i<10; i++) {
        //为了创建并插入一个新的实体实例到默认上下文对象中
        Person *person = [Person MR_createEntity];
        person.age =@(25+i);
        person.firstName = [NSString stringWithFormat:@"JSKKSK%ld",i];
        person.lastName = [NSString stringWithFormat:@"XXMMXM%ld",i];
        [[NSManagedObjectContext MR_defaultContext] MR_saveOnlySelfAndWait];
    }
    
    
    
    
    NSArray *personArray = [Person MR_findAll];
    if (personArray.count>0) {
        for (Person *person in personArray) {
            NSLog(@"firstName:%@    lastName:%@    age:%@",person.firstName,person.lastName,person.age);
        }
    }
    
    NSLog(@"--------------------------------");
    NSArray *findAttributeArray = [Person MR_findByAttribute:@"age" withValue:@(25) andOrderBy:@"age" ascending:NO];
    if (findAttributeArray.count>0) {
        for (Person *person in findAttributeArray) {
            NSLog(@"firstName:%@    lastName:%@    age:%@",person.firstName,person.lastName,person.age);
        }
    }
    
    NSLog(@"--------------------------------");
    
    Person *firstData= [Person MR_findFirst];
    NSLog(@"firstName:%@    lastName:%@    age:%@",firstData.firstName,firstData.lastName,firstData.age);
    NSLog(@"--------------------------------");
    
    
    NSArray *deleteArray = [Person MR_findByAttribute:@"age" withValue:@(28) andOrderBy:@"age" ascending:NO];
    if (deleteArray.count>0) {
        Person *tempPerson = deleteArray[0];
        [tempPerson MR_deleteEntity];
        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    }
    NSLog(@"--------------------------------");
    
    NSArray *personArrays = [Person MR_findAll];
    if (personArrays.count>0) {
        for (Person *person in personArrays) {
            NSLog(@"firstName:%@    lastName:%@    age:%@",person.firstName,person.lastName,person.age);
        }
        
    }
    

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    /*
     通常,你的应用应该在数据变化时,将其保存到持久化存储层中.有些应用选择仅在应用结束时保存,但是在大多数情况下并不需要这样做 - 实际上,如果你仅在应用退出时保存数据,很有可能会丢失数据!如果你的应用闪退了,会生什么?用户会丢失所有已经保存的数据 - 这是一种非常糟糕的用户体验,却又很容易避免.
     
     如果你发现保存操作耗费了很长时间,你应该考虑使用一些方式优化:
     
     在后台线程保存: MagicalRecord 提供了一种简捷的API来改变并立即在后台线程保存数据 - 例如:
     
     [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
     
     // Do your work to be saved here, against the `localContext` instance
     // Everything you do in this block will occur on a background thread
     
     } completion:^(BOOL success, NSError *error) {
     [application endBackgroundTask:bgTask];
     bgTask = UIBackgroundTaskInvalid;
     }];
     把任务分割成小块的保存任务: 某些数据量较大的任务,如导入大量的数据,应该被分割成更小块的保存任务.没有统一的标准规定单次保存多少任务最合适,所以你需要使用工具来测试你的应用工的性能以针对自己的应用进行调整.工具可选使用 Apple的 Instruments.
     
     处理需要长时间运行的保存任务
     
     当iOS应用退出时,有一个较短的时间来整理和保存数据到磁盘.如果你确定某个保存操作很可能会花费一定时间,最好的方式是请求延长应用的生命周期,比如这样:
     
     UIApplication *application = [UIApplication sharedApplication];
     
     __block UIBackgroundTaskIdentifier bgTask = [application beginBackgroundTaskWithExpirationHandler:^{
     [application endBackgroundTask:bgTask];
     bgTask = UIBackgroundTaskInvalid;
     }];
     
     [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
     
     // 这里有任何保存操作
     
     } completion:^(BOOL success, NSError *error) {
     [application endBackgroundTask:bgTask];
     bgTask = UIBackgroundTaskInvalid;
     }];
     */
    // Dispose of any resources that can be recreated.
}

@end
