//
//  RSTFileBrowserViewController.m
//
//  Created by InfiniDev on 6/9/13.
//  Copyright (c) 2013 InfiniDev. All rights reserved.
//

#import "RSTFileBrowserViewController.h"
#import "DocWatchHelper.h"
#import <Dropbox/Dropbox.h>

@interface RSTFileBrowserViewController ()

@property (strong, nonatomic) NSMutableDictionary *fileDictionary;
@property (strong, nonatomic) NSArray *sections;
@property (strong, nonatomic) DocWatchHelper *docWatchHelper;
@property (strong, nonatomic) NSArray *contents;
@property (strong, nonatomic) DBAccount *account;
@property (strong, nonatomic) DBFilesystem *fileSystem;

@end

@implementation RSTFileBrowserViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        [self initialize];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initialize];
    }
    
    return self;
}

- (void)initialize {
    _fileDictionary = [[NSMutableDictionary alloc] init];
    _sections = [@"A|B|C|D|E|F|G|H|I|J|K|L|M|N|O|P|Q|R|S|T|U|V|W|X|Y|Z|#" componentsSeparatedByString:@"|"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshDirectory) name:kDocumentChanged object:nil]; // Don't set the object because the actual DocWatchHelper object changes each time the directory changes
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _account = [DBAccountManager sharedManager].linkedAccount;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Public

- (NSString *)filepathForIndexPath:(NSIndexPath *)indexPath {
    NSString *filename = [[self.fileDictionary objectForKey:[self.sections objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
    return [self.currentDirectory stringByAppendingPathComponent:filename];
}

#pragma mark - Refreshing Data

- (void)refreshDirectory {
    [self.fileDictionary removeAllObjects];
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    _contents = [fileManager contentsOfDirectoryAtPath:self.currentDirectory error:nil];
    NSArray *extensions = [self.supportedFileExtensions copy];
        
    for (NSString *filename in _contents) {
        BOOL fileSupported = NO;
        BOOL isDirectory = NO;
        
        [fileManager fileExistsAtPath:[self.currentDirectory stringByAppendingPathComponent:filename] isDirectory:&isDirectory];
        
        if (isDirectory)
        {
            fileSupported = self.showFolders;
        }
        else
        {
            if ([self.supportedFileExtensions count] == 0)
            {
                fileSupported = YES;
            }
            else
            {
                for (NSString *extension in extensions)
                {
                    if ([[[filename pathExtension] lowercaseString] isEqualToString:[extension lowercaseString]])
                    {
                        fileSupported = YES;
                        break;
                    }
                }
            }
        }
        
        if (fileSupported) {
            NSString *characterIndex = [filename substringWithRange:NSMakeRange(0,1)];
            characterIndex = [characterIndex uppercaseString];
                        
            if ([characterIndex rangeOfCharacterFromSet:[NSCharacterSet uppercaseLetterCharacterSet]].location == NSNotFound) {
                characterIndex = @"#";
            }
            
            NSMutableArray *sectionArray = self.fileDictionary[characterIndex];
            if (sectionArray == nil) {
                sectionArray = [[NSMutableArray alloc] init];
            }
            [sectionArray addObject:filename];
            self.fileDictionary[characterIndex] = sectionArray;
        }
    }
        
    [self.tableView reloadData];
        
    if ([self.delegate respondsToSelector:@selector(fileBrowserViewController:didRefreshDirectory:)]) {
        [self.delegate fileBrowserViewController:self didRefreshDirectory:self.currentDirectory];
    }
}

- (void)setCurrentDirectory:(NSString *)currentDirectory {
    if ([_currentDirectory isEqualToString:currentDirectory]) {
        return;
    }
    
    _currentDirectory = [currentDirectory copy];
    [self refreshDirectory];
    
    self.docWatchHelper = [DocWatchHelper watcherForPath:_currentDirectory];
}

#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    NSString *filename = [[self.fileDictionary objectForKey:[self.sections objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
    
    if (self.showFileExtensions == NO) {
        filename = [filename stringByDeletingPathExtension];
    }
    
    cell.textLabel.text = filename;
    
    return cell;
}

#pragma mark Sections

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger numberOfSections = self.sections.count;
    return numberOfSections > 0 ? numberOfSections : 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *sectionTitle = nil;
    if (self.sections.count) {
        NSInteger numberOfRows = [self tableView:tableView numberOfRowsInSection:section];
        if (numberOfRows > 0) {
            sectionTitle = [self.sections objectAtIndex:section];
        }
    }
    return sectionTitle;
}
/*
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return self.sections;
}
*/
- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    return index;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger numberOfRows = self.fileDictionary.count;
    if (self.sections.count) {
        numberOfRows = [[self.fileDictionary objectForKey:[self.sections objectAtIndex:section]] count];
    }
    return numberOfRows;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

@end
