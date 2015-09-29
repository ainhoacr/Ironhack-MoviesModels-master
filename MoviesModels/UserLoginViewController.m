//
//  UserLoginViewController.m
//  MoviesModels
//
//  Created by Alexander Valero on 29/9/15.
//  Copyright © 2015 Ironhack. All rights reserved.
//

#import "UserLoginViewController.h"
#import "UserEntity.h"

@interface UserLoginViewController ()
@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;

@end

@implementation UserLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)loginButton:(UIButton *)sender {
    
    if (self.usernameField.text.length && self.passwordField.text.length) {
        [self loginUserWithUserName:self.usernameField.text andPassword:self.passwordField.text];
    }
    else{
        NSLog(@"Invalid input");
    }
}


-(void)loginUserWithUserName: (NSString *)username andPassword:(NSString *)password{
    
    UserEntity *loggedUser = [self loggedUserWithUserName:username andPassword:password];
    if (!loggedUser) {
        loggedUser = [self addUserWithUserName:username andPassword:password];
    }
    if (loggedUser) {
        [self saveUserDefaults];
        [[NSNotificationCenter defaultCenter] postNotificationName:UserLoggedNotification object:loggedUser];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

-(UserEntity *)loggedUserWithUserName: (NSString *)username andPassword:(NSString *)password{
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"UserEntity"];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"name = %@ AND password = %@", username, password];
    NSError *error;
    NSArray *fetchResult=[self.context executeFetchRequest:fetchRequest error:&error];
    return fetchResult.count?[fetchResult firstObject]:nil;
    
}


-(UserEntity *)addUserWithUserName: (NSString *)username andPassword:(NSString *)password{
    
    UserEntity *user = [NSEntityDescription insertNewObjectForEntityForName:@"UserEntity"inManagedObjectContext:self.context];
    user.name=username;
    user.password=password;
    NSError *error;
    [self.context save:&error];
    return user;
}

- (void)saveUserDefaults
{
    [[NSUserDefaults standardUserDefaults]setObject:[NSDate date] forKey:@"lastLoginDate"];
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
