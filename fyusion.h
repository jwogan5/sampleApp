/**
 * ifyusion
 *
 * Created by Your Name
 * Copyright (c) 2018 Your Company. All rights reserved.
 */

#import "TiModule.h"
@import FyuseSessionTagging;

@interface ComTraderinteractiveFyusionModule : TiModule <FYSessionViewControllerDelegate, FYUploadSessionManagerDelegate>{
    FYUploadSessionManager *fyuseUploadManager;
    FYFyuse *fyuse;
}

@property(nonatomic,readonly) NSString *sessionId;


@end
