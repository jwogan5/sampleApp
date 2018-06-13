/**
 * ifyusion
 *
 * Created by Your Name
 * Copyright (c) 2018 Your Company. All rights reserved.
 */

#import "ComTraderinteractiveFyusionModule.h"
#import "TiBase.h"
#import "TiHost.h"
#import "TiUtils.h"
#import "TiApp.h"


@implementation ComTraderinteractiveFyusionModule


#pragma mark Internal

// This is generated for your module, please do not change it
- (id)moduleGUID
{
  return @"6bd3cdbd-b232-42c3-b39d-2e235a9947ca";
}

// This is generated for your module, please do not change it
- (NSString *)moduleId
{
  return @"com.traderinteractive.fyusion";
}

#pragma mark Lifecycle

- (void)startup
{
  // This method is called when the module is first loaded
  // You *must* call the superclass
  [super startup];
  DebugLog(@"[DEBUG] %@ loaded", self);

  [FYAuthManager initializeWithAppID: @"vgjN_pN5Twoz8EKVe69yOJ" appSecret: @"4oFb5XT3X2gr27NU7On5sILcluG3gZrf"];
}

#pragma Public APIs

- (NSString *)getVersion
{
    return @"0.0.1";
}

- (void)getSessionId
{
    return _sessionId;
}


/*
    Create Fyusion Methods
*/
- (void)startSession:(id)args
{
    ENSURE_SINGLE_ARG(args,NSDictionary);
    _sessionId = [TiUtils stringValue:@"id" properties:args];

    if ([_sessionId length] != 0) {
        NSLog(@"Master Fyusion Detected");
        FYSessionViewController *fyuseSession = [[FYSessionViewController alloc] initWithSessionIdentifier:_sessionId];
        fyuseSession.sessionDelegate = self;
        [[TiApp app] showModalController: fyuseSession animated: YES];
    } else {
        NSLog(@"Brand New Fyusion");
        FYSessionViewController *fyuseSession = [[FYSessionViewController alloc] init];
        fyuseSession.sessionDelegate = self;
        [[TiApp app] showModalController: fyuseSession animated: YES];
    }
}

- (void)sessionControllerDidDismiss:(FYSessionViewController *)sessionController{
    NSLog(@"Closing Fyusion Camera");
    
    if ([self _hasListeners:@"response"]) {
        [self fireEvent:@"response" withObject:@{ @"message": @"Closing Fyusion Camera",  @"reason": @"user exit"}];
    }
}

- (void)sessionController:(FYSessionViewController *)sessionController didSaveSessionWithIdentifier:(NSString *)identifier {
    // This is a local identifier. Need to upload this to their server.
    NSLog(@"%@", identifier);
    
    if ([self _hasListeners:@"response"]) {
        [self fireEvent:@"response" withObject:@{ @"message": @"Closing Fyusion Camera", @"reason": @"Saved a Local Session", @"localId": identifier}];
    }
}









/*
    Upload Fyusion Methods
 */
- (void)uploadSessionWithId:(id)args
{
    ENSURE_SINGLE_ARG(args,NSDictionary);
    NSString *localId = [TiUtils stringValue:@"id" properties:args];
   
    // Upload the session and then listen for it
    fyuseUploadManager = [FYUploadSessionManager new];
    fyuseUploadManager.delegate = self;
    fyuseUploadManager.disableBackgroundUpload = YES;
    [fyuseUploadManager uploadSessionWithIdentifier:localId];
}


- (void)sessionFinishedUploadingWithUID:(NSString *)uid {
    NSLog(@"Fyusion Upload Successful");
    if ([self _hasListeners:@"response"]) {
        [self fireEvent:@"response" withObject:@{ @"message": @"Uploading Fyusion Success", @"remoteId": uid}];
    }
}

- (void)sessionFailedUploading{
    NSLog(@"Fyusion Upload Failed");
    if ([self _hasListeners:@"response"]) {
        [self fireEvent:@"response" withObject:@{ @"message": @"Uploading Fyusion Failed"}];
    }
}

- (void)sessionUpdatedUploadProgress:(CGFloat)progress{
    NSString *p = [NSString stringWithFormat:@"%1.2f", progress];
    if ([self _hasListeners:@"response"]) {
        [self fireEvent:@"response" withObject:@{ @"message": @"Uploading Progress Final", @"progress":p}];
    }
}

- (void)sessionUpdatedUploadPreparationProgress:(CGFloat)progress{
    NSString *p = [NSString stringWithFormat:@"%1.2f", progress];
    if ([self _hasListeners:@"response"]) {
        [self fireEvent:@"response" withObject:@{ @"message": @"Uploading Progress Prep", @"progress":p}];
    }
}











/*
   Manage Fyusions
*/
- (void)fetchLocalIds
{
    NSArray *ids = [FYSessionManager allSessionIDs];
    NSLog(@"%@", ids);
    if ([self _hasListeners:@"response"]) {
        [self fireEvent:@"response" withObject:@{ @"message": @"Local Ids", @"ids": ids}];
    }
}





/*
 View Fyusions
 */
-(void)viewFyuseWithId:(id)args
{
    ENSURE_SINGLE_ARG(args,NSDictionary);
    NSString *fyuseId = [TiUtils stringValue:@"id" properties:args];
    NSString *fyuseLocation = [TiUtils stringValue:@"location" properties:args];

    if ([fyuseLocation isEqualToString:@"local"]) {
        FYFyuseManager *fymanager = [FYFyuseManager sharedManager];
        FYDiskCache *diskCache = fymanager.diskCache;
        NSLog(@"Loaded a fyuse from disk");
        [self showFyuse:[diskCache objectForKeyedSubscript:fyuseId]];
    } else {
        FYFyuseManager *fymanager = [FYFyuseManager sharedManager];
        [fymanager requestFyuseWithUID:fyuseId onSuccess:^(FYFyuse *f) {
            NSLog(@"Fetched a remote fyuse.");
            [self showFyuse:f];
        } onFailure:^(NSError *error) {
            NSLog(@"Failed to load a fyuse");
            if ([self _hasListeners:@"response"]) {
                [self fireEvent:@"response" withObject:@{ @"message": @"Could Not Load Fyuse", @"id": fyuseId}];
            }
        }];
    }
}

- (void)showFyuse:(FYFyuse *) theFyuse
{
    NSLog(@"A Fyuse is Ready for Display");
    NSLog(@"%@", [theFyuse class]);
    fyuse = theFyuse;
}


@end
