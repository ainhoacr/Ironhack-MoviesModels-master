//
//  UserLoginViewController.h
//  MoviesModels
//
//  Created by Alexander Valero on 29/9/15.
//  Copyright © 2015 Ironhack. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString *const UserLoggedNotification = @"userLoggedNotification";

@interface UserLoginViewController : UIViewController

@property (strong, nonatomic) NSManagedObjectContext *context;


@end
