/******************************************************************************
 *
 *       Copyright Zebra Technologies, Inc. 2014 - 2015
 *
 *       The copyright notice above does not evidence any
 *       actual or intended publication of such source code.
 *       The code contains Zebra Technologies
 *       Confidential Proprietary Information.
 *
 *
 *  Description:  RFIDDemoAppDelegate.m
 *
 *  Notes:
 *
 ******************************************************************************/

#import "RFIDDemoAppDelegate.h"
#import "RfidAppEngine.h"
#import "ScannerEngine.h"
#import "ui_config.h"

@implementation zt_RfidDemoAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    [zt_RfidAppEngine sharedAppEngine];
    [ScannerEngine sharedScannerEngine];
    
    // Clear the array stored in NSUserDefaults
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        //[defaults removeObjectForKey:@"SelectedItemsArray"];
        [defaults synchronize];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
    {
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeBadge|UIUserNotificationTypeSound|UIUserNotificationTypeAlert) categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    }
    
    UILocalNotification *bg_notification = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
    if (bg_notification)
    {
        [[UIApplication sharedApplication] cancelAllLocalNotifications];
    }
    /// Firmware update download folder creation
    [self createDownloadFolderInDocumentDirectory];
    
    if (@available(iOS 15, *)){
            UINavigationBarAppearance *appearance = [[UINavigationBarAppearance alloc] init];
            [appearance configureWithOpaqueBackground];
            appearance.titleTextAttributes = @{NSForegroundColorAttributeName : UIColor.whiteColor};
            appearance.backgroundColor = [UIColor colorWithRed:63/255.0 green:142/255.0 blue:202/255.0 alpha:1.0];
            [UINavigationBar appearance].standardAppearance = appearance;
            [UINavigationBar appearance].scrollEdgeAppearance = appearance;
        
       
        
        }
    
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(savePreFilterTagIDData:) name:@"SaveTagIDsDataNotification" object:nil];
    return YES;
}

- (void)savePreFilterTagIDData:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    NSString *tagID_1 = userInfo[@"tagID_1_Val"];
    NSString *tagID_2 = userInfo[@"tagID_2_Val"];
    
    NSUserDefaults *SelectedDefaults = [NSUserDefaults standardUserDefaults];
    NSArray *selectedItems = @[tagID_1, tagID_2];
    [SelectedDefaults setObject:selectedItems forKey:@"SelectedItemsArray"];
    [SelectedDefaults synchronize];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:ZT_AUTO_CONNECT_TERMINATE_STATE];
    
}


/// Create download folder
/// @param rootDir Root directory path
- (void)createDownloadFolderInDocumentDirectory {
    NSString *documentDirectory = [NSHomeDirectory() stringByAppendingPathComponent:ZT_PLUGIN_DEFAULT_DOCUMENT];
    NSString *downloadDirectory = [documentDirectory stringByAppendingPathComponent:ZT_FW_FILE_DIRECTIORY_NAME];
    BOOL isDirectory = YES;
    if (![[NSFileManager defaultManager] fileExistsAtPath:downloadDirectory isDirectory:&isDirectory] || !isDirectory) {
        NSError *error = nil;
        NSDictionary *attr = [NSDictionary dictionaryWithObject:NSFileProtectionComplete
                                                         forKey:NSFileProtectionKey];
        [[NSFileManager defaultManager] createDirectoryAtPath:downloadDirectory
                                  withIntermediateDirectories:YES
                                                   attributes:attr
                                                        error:&error];
        if (error)
            NSLog(@"Error creating directory path: %@", [error localizedDescription]);
    }
}

@end
