//
//  ShowsTableViewController.m
//  MoviesModels
//
//  Created by Joan Romano on 9/27/15.
//  Copyright © 2015 Ironhack. All rights reserved.
//

#import "ShowsTableViewController.h"

#import "Show.h"
#import "ShowsProvider.h"
#import "NSArray+Random.h"
#import "NSString+Random.h"
#import "UserEntity.h"
#import "UserLoginViewController.h"

static NSString * const savedShowsFileName = @"shows";

@interface ShowsTableViewController () <UITabBarControllerDelegate>

@property (strong,nonatomic) NSMutableArray *shows;
@property (strong,nonatomic) ShowsProvider *showsProvider;
@property (strong, nonatomic) NSMutableArray *likes;
@property (strong, nonatomic) NSString *userName;
@property (strong, nonatomic) NSString *path;

@end

@implementation ShowsTableViewController

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self)
    {
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(changeTitle:) name:UserLoggedNotification object:nil];
        self.title = @"Shows";
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.shows = [NSMutableArray array];

    UIBarButtonItem *saveShowsButton = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(saveShows:)];
    self.navigationItem.leftBarButtonItem = saveShowsButton;
    UIBarButtonItem *duplicateMovieButton = [[UIBarButtonItem alloc] initWithTitle:@"Duplicate" style:UIBarButtonItemStylePlain target:self action:@selector(addDuplicatedShow:)];
    UIBarButtonItem *addMovieButton = [[UIBarButtonItem alloc] initWithTitle:@"Add" style:UIBarButtonItemStylePlain target:self action:@selector(addShow:)];
    self.navigationItem.rightBarButtonItems = @[duplicateMovieButton, addMovieButton];
    
    self.showsProvider = [[ShowsProvider alloc] init];
    self.shows = [[self.showsProvider showsFromRemote] mutableCopy];
}

- (void)addDuplicatedShow:(id)sender
{
    [self.shows addObject:[self.shows mm_randomObject]];
    
    [self.tableView reloadData];
}

- (void)addShow:(id)sender
{
    [self.shows addObject:[self randomShow]];
    [self.tableView reloadData];
}

- (Show *)randomShow
{
    Show *show = [[Show alloc] init];
    show.showId = [NSString mm_randomString];
    show.showTitle = [NSString mm_randomString];
    show.showDescription = [NSString mm_randomString];
    show.showRating = arc4random()/10.0f;
    
    return show;
}

- (NSString *)archivePath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths firstObject];
    
    return [documentsDirectory stringByAppendingPathComponent:savedShowsFileName];
}

- (void)saveShows:(id)sender
{
    if (self.shows.count)
    {
        [NSKeyedArchiver archiveRootObject:self.shows toFile:[self archivePath]];
        [self saveLikes];
    }
}

- (void)loadShows
{
    NSArray *shows = [NSKeyedUnarchiver unarchiveObjectWithFile:[self archivePath]];
    if (shows.count)
    {
        self.shows = [shows mutableCopy];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (![self loggedUser]) {
        [self presentLoginView];
    }
    else
    {
        self.userName = [self loggedUser].name;
        self.navigationItem.title = self.userName;
        NSString *documentsDirectory = nil;
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        documentsDirectory = [paths objectAtIndex:0];
        NSString *namePath = [NSString stringWithFormat:@"%@_saves.plist", self.userName];
        self.path = [documentsDirectory stringByAppendingPathComponent:namePath];
        [self loadLikes];
    }
}

- (UserEntity *)loggedUser
{
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"UserEntity"];
    NSError *error;
    NSArray *fetchResult=[self.context executeFetchRequest:fetchRequest error:&error];
    return [fetchResult firstObject];
}

- (void)presentLoginView
{
    [self performSegueWithIdentifier:@"segueLogin" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    UserLoginViewController *userLoginVC = segue.destinationViewController;
    userLoginVC.context = self.context;
}

- (void)saveLikes
{
    if (self.path) {
        [@{@"likes":self.likes} writeToFile:self.path atomically:YES];
    }
}

- (void)loadLikes
{
    if (self.path)
    {
        NSDictionary *dictonaryLikes = [NSDictionary dictionaryWithContentsOfFile:self.path];
        self.likes = [[dictonaryLikes objectForKey:@"likes"] mutableCopy];
        [self.tableView reloadData];
    }
}

#pragma mark - Notification

- (void)changeTitle:(NSNotification *)notification
{
    UserEntity *loggedUser = notification.object;
    [self navigationItem].title = loggedUser.name;
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.shows.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Show *show = self.shows[indexPath.item];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reuseIdentifier" forIndexPath:indexPath];
    if ([self.likes containsObject:@(indexPath.row)]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }

    cell.textLabel.text = show.showTitle;
    cell.detailTextLabel.text = show.showDescription;
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.likes containsObject:@(indexPath.row)])
    {
        [self.likes removeObject:@(indexPath.row)];
    }
    else
    {
        [self.likes addObject:@(indexPath.row)];
    }
    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    
    
}

- (void)compareWithFirstShow:(Show *)show
{
    UIAlertController *alert;
    Show *firstShow=[self.shows firstObject];
    
    if ([firstShow isEqual:show])
    {
        alert = [UIAlertController alertControllerWithTitle:@"Equal Show" message:@"It is equal !!" preferredStyle:UIAlertControllerStyleAlert];
    }
    else
    {
        alert = [UIAlertController alertControllerWithTitle:@"Equal Show" message:@"IIt is NOT equal" preferredStyle:UIAlertControllerStyleAlert];
    }
    
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
        [alert dismissViewControllerAnimated:YES completion:nil];
        
    }];
    [alert addAction:ok];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)findShow:(Show *)show
{
    UIAlertController *alert;
    
    if ([self.shows containsObject:show])
    {
        alert = [UIAlertController alertControllerWithTitle:@"Find Show" message:@"Found !" preferredStyle:UIAlertControllerStyleAlert];
    }
    else
    {
        alert = [UIAlertController alertControllerWithTitle:@"Find Show" message:@"Not in dataSource" preferredStyle:UIAlertControllerStyleAlert];
    }
    
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
        [alert dismissViewControllerAnimated:YES completion:nil];
        
    }];
    [alert addAction:ok];
    [self presentViewController:alert animated:YES completion:nil];
}

- (NSMutableArray *)likes
{
    if (!_likes) {
        _likes = [[NSMutableArray alloc]init];
    }
    return _likes;
}

@end
