//
//  NDSGame.m
//  nds4ios
//
//  Created by Zydeco on 16/7/2013.
//  Copyright (c) 2013 DS Team. All rights reserved.
//

#import "NDSGame.h"

NSString * const NDSGameSaveStatesChangedNotification = @"NDSGameSaveStatesChangedNotification";

@implementation NDSGame
{
    NSArray *saveStates;
}

+ (NSArray*)gamesAtPath:(NSString*)gamesPath saveStateDirectoryPath:(NSString*)saveStatePath
{
    NSMutableArray *games = [NSMutableArray new];
    NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:gamesPath error:NULL];
    for(NSString *file in files) {
        NDSGame *game = [NDSGame gameWithPath:[gamesPath stringByAppendingPathComponent:file] saveStateDirectoryPath:saveStatePath];
        if (game) [games addObject:game];
    }
    
    return [NSArray arrayWithArray:games];
}

+ (NDSGame*)gameWithPath:(NSString*)path saveStateDirectoryPath:(NSString*)saveStatePath
{
    return [[NDSGame alloc] initWithPath:path saveStateDirectoryPath:saveStatePath];
}

- (NDSGame*)initWithPath:(NSString*)path saveStateDirectoryPath:(NSString*)saveStatePath
{
    NSAssert(path.isAbsolutePath, @"NDSGame path must be absolute");
    if (![path.pathExtension.lowercaseString isEqualToString:@"nds"]) return nil;
    
    // check file exists
    BOOL isDirectory = NO;
    if (![[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDirectory] || isDirectory) return nil;
    
    if ((self = [super init])) {
        self.path = path;
        self.pathForSavedStates = saveStatePath;
        [self _loadSaveStates];
    }
    return self;
}

- (void)_loadSaveStates
{
    // get save states (<ROM name without extension>.<save state name>.dsv)
    NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:self.pathForSavedStates error:NULL];
    NSString *savePrefix = [self.path.lastPathComponent.stringByDeletingPathExtension stringByAppendingString:@"."];
    saveStates = [files objectsAtIndexes:[files indexesOfObjectsPassingTest:^BOOL(NSString *filename, NSUInteger idx, BOOL *stop) {
        return ([filename.pathExtension isEqualToString:@"dsv"] && [filename.stringByDeletingPathExtension hasPrefix:savePrefix]);
    }]];
    
    NSFileManager *fm = [NSFileManager defaultManager];
    saveStates = [saveStates sortedArrayUsingComparator:^NSComparisonResult(NSString *s1, NSString *s2) {
        if ([s1 hasSuffix:@".pause.dsv"]) return NSOrderedAscending;
        if ([s2 hasSuffix:@".pause.dsv"]) return NSOrderedDescending;
        NSDate *date1 = [fm attributesOfItemAtPath:[self.pathForSavedStates stringByAppendingPathComponent:s1] error:NULL].fileModificationDate;
        NSDate *date2 = [fm attributesOfItemAtPath:[self.pathForSavedStates stringByAppendingPathComponent:s1] error:NULL].fileModificationDate;
        return [date1 compare:date2];
    }];
}

- (void)reloadSaveStates
{
    [self _loadSaveStates];
    [[NSNotificationCenter defaultCenter] postNotificationName:NDSGameSaveStatesChangedNotification object:self userInfo:nil];
}

- (NSString*)title
{
    return self.path.lastPathComponent.stringByDeletingPathExtension;
}

- (NSInteger)numberOfSaveStates
{
    return saveStates.count;
}

- (BOOL)deleteSaveStateAtIndex:(NSInteger)idx
{
    if (idx < 0 || idx >= saveStates.count) return NO;
    if (![[NSFileManager defaultManager] removeItemAtPath:[self pathForSaveStateAtIndex:idx] error:NULL]) return NO;
    [self reloadSaveStates];
    return YES;
}

- (NSString*)pathForSaveStateWithName:(NSString*)name
{
    name = [NSString stringWithFormat:@"%@.%@.dsv", self.path.lastPathComponent.stringByDeletingPathExtension, name];
    return [self.pathForSavedStates stringByAppendingPathComponent:name];
}

- (NSString*)pathForSaveStateAtIndex:(NSInteger)idx
{
    if (idx < 0 || idx >= saveStates.count) return nil;
    return [self.pathForSavedStates stringByAppendingPathComponent:saveStates[idx]];
}

- (NSString*)nameOfSaveStateAtIndex:(NSInteger)idx
{
    if (idx < 0 || idx >= saveStates.count) return nil;
    return [[saveStates[idx] substringFromIndex:self.path.lastPathComponent.stringByDeletingPathExtension.length+1] stringByDeletingPathExtension];
}

- (NSDate*)dateOfSaveStateAtIndex:(NSInteger)idx
{
    if (idx < 0 || idx >= saveStates.count) return nil;
    return [[NSFileManager defaultManager] attributesOfItemAtPath:[self pathForSaveStateAtIndex:idx] error:NULL].fileModificationDate;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<NDSGame 0x%p: %@>", self, self.path];
}

@end
