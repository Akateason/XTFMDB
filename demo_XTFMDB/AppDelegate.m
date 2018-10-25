//
//  AppDelegate.m
//  demo_XTFMDB
//
//  Created by teason23 on 2017/5/4.
//  Copyright © 2017年 teaason. All rights reserved.
//

#import "AppDelegate.h"
#import "AnyModel.h"
#import "XTFMDB/XTFMDB.h"
#import <YYModel/YYModel.h>


@interface AppDelegate ()

@end


@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // 在这初始化数据库
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                         NSUserDomainMask,
                                                         YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    documentsDirectory =
        [documentsDirectory stringByAppendingString:@"/akateason"];
    [XTFMDBBase sharedInstance].isDebugMode = YES;
    [[XTFMDBBase sharedInstance] configureDBWithPath:documentsDirectory];

    //    升级数据库
    //    [[XTFMDBBase sharedInstance] dbUpgradeTable:CustomDBModel.class
    //                                      paramsAdd:@[@"a1",@"a2",@"a3"]
    //                                        version:2] ;
    //
    //    [[XTFMDBBase sharedInstance] dbUpgradeTable:Model1.class
    //                                      paramsAdd:@[@"b1",@"b2",@"b3"]
    //                                        version:3] ;

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state.
    // This can occur for certain types of temporary interruptions (such as an
    // incoming phone call or SMS message) or when the user quits the application
    // and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate
    // graphics rendering callbacks. Games should use this method to pause the
    // game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate
    // timers, and store enough application state information to restore your
    // application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called
    // instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state;
    // here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the
    // application was inactive. If the application was previously in the
    // background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if
    // appropriate. See also applicationDidEnterBackground:.
}

@end
