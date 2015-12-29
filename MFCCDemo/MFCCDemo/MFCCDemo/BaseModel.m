//
//  BaseModel.m
//  Bone
//
//  Created by Hai Le on 5/3/15.
//  Copyright (c) 2015 Hai Le. All rights reserved.
//

#import "BaseModel.h"
#import "DataManager.h"

@implementation BaseModel

@synthesize translated = _translated;

- (id)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    if (self) {

    }
    return self;
}

- (id)translated {
    AppTranslator* at = [AppTranslator shared];
    AppService* as = [AppService shared];
    if (![at.currentTranslation isEqualToString:as.currentServerString]) {
        NSString *strClass = NSStringFromClass([self class]);
        id translated = [[DataManager shared] getEntityByClass:strClass
                                                       byStrID:_IDString
                                                   translation:at.currentTranslation];
        if (!translated)
            return self;
        else
            _translated = translated;
        return translated;
    }
    return self;
}

@end
