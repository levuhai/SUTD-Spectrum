//
//  BaseModel.h
//  Bone
//
//  Created by Hai Le on 5/3/15.
//  Copyright (c) 2015 Hai Le. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BaseModel : NSObject

@property(strong, nonatomic) id translated;
@property(nonatomic, assign) int ID;
@property(strong, nonatomic) NSString* IDString;
@property(strong, nonatomic) NSString *iconStr;

- (id)initWithDictionary:(NSDictionary *)dict;

@end
