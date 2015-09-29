//
//  ProfileViewController.m
//  MoviesModels
//
//  Created by Alexander Valero on 29/9/15.
//  Copyright © 2015 Ironhack. All rights reserved.
//

#import "ProfileViewController.h"
#import "UserLoginViewController.h"
#import "UserEntity.h"

@interface ProfileViewController ()
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;

@end

@implementation ProfileViewController


- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self)
    {
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(updateData:) name:UserLoggedNotification object:nil];
        self.title = @"Profile";
    }
    
    return self;
}



-(void)updateData: (NSNotification *)notification
{
    UserEntity *loggedUser = notification.object;
    self.usernameLabel.text = loggedUser.name;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    self.usernameLabel.text = [self loggedUser].name;
}

- (UserEntity *)loggedUser
{
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"UserEntity"];
    NSError *error;
    NSArray *fetchResult=[self.context executeFetchRequest:fetchRequest error:&error];
    return [fetchResult firstObject];
}

- (IBAction)logoutButton:(UIButton *)sender
{
    [self removeDirectoryCaches];
    [self removeUserContext];
    UserLoginViewController *loginVC = [self.storyboard instantiateViewControllerWithIdentifier:@"userLoginViewController"];
    loginVC.context = self.context;
    [self presentViewController:loginVC animated:YES completion:^{
        self.tabBarController.selectedIndex = 0;
    }];
}

- (void)removeDirectoryCaches
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    NSString *documentsDirectory = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    documentsDirectory = [paths objectAtIndex:0];
    NSString *namePath = [NSString stringWithFormat:@"%@_saves.plist", [self loggedUser].name];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:namePath];
    if (![fileManager removeItemAtPath:path error:&error])
    {
        NSLog(@"[Error] %@  (%@)", error, path);
    }
}


-(void)removeUserContext
{
    [self.context deleteObject:[self loggedUser]];
    NSError *error;
    [self.context save:&error];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
