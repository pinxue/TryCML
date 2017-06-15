//
//  SceneImageAnalyzer.h
//  TryCML
//
//  Created by YangWu on 15/06/2017.
//  Copyright © 2017 Yang Wu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIImage.h>
@interface SceneImageAnalyzer : NSObject
- initWithUrl:(NSURL*)url;
- (NSString*) analyzeImage:(UIImage*)origImg allPossible:(NSMutableDictionary*)all;
@end
