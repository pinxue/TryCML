//
//  SceneImageAnalyzer.m
//  TryCML
//
//  Created by YangWu on 15/06/2017.
//  Copyright © 2017 Yang Wu. All rights reserved.
//

#import "SceneImageAnalyzer.h"
#import "GoogLeNetPlaces.h"
@import UIKit;

@interface SceneImageAnalyzer()
  @property (nonatomic,strong) GoogLeNetPlaces * model;
@end
@implementation SceneImageAnalyzer

- (SceneImageAnalyzer*)initWithUrl:(NSURL*)url {
  self = [super init];
  self.model = [[GoogLeNetPlaces alloc] initWithContentsOfURL:url error:nil];
  return self;
}

- (NSString*) analyzeImage:(UIImage*)origImg allPossible:(NSMutableDictionary*)all {
  CGSize size =CGSizeMake(224, 224);
  UIImage * img = [self fitImage:origImg toSize:size];
  CVPixelBufferRef imgBuf = NULL;
  CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault,
                                        size.width,
                                        size.height,
                                        kCVPixelFormatType_32ARGB,
                                        (__bridge CFDictionaryRef) @{(__bridge NSString *) kCVPixelBufferIOSurfacePropertiesKey: @{}},
                                        &imgBuf);
  if ( status == kCVReturnSuccess ) {
    CIImage *ciImg = [CIImage imageWithCGImage:img.CGImage];
    NSError * err;
    CIContext *ciContext = [CIContext contextWithCGContext:UIGraphicsGetCurrentContext() options:nil];
    [ciContext render:ciImg toCVPixelBuffer:imgBuf];
    GoogLeNetPlacesOutput * result = [self.model predictionFromSceneImage:imgBuf error:&err];
    if ( err ) {
      return [err description];
    } else {
      [all addEntriesFromDictionary:result.sceneLabelProbs];
      return result.sceneLabel;
    }
  }

  return @"I need more training.";
}

- (UIImage *)fitImage:(UIImage *)image toSize:(CGSize)size {
  CGFloat wfactor = size.width / image.size.width;
  CGFloat hfactor = size.height / image.size.height;
  CGFloat scaleFactor = wfactor>hfactor ? wfactor : hfactor;

  UIGraphicsBeginImageContext(size);
  CGRect rect = CGRectMake((size.width - image.size.width * scaleFactor) / 2,
                           (size.height -  image.size.height * scaleFactor) / 2,
                           image.size.width * scaleFactor, image.size.height * scaleFactor);

  [image drawInRect:rect];

  UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();

  return scaledImage;
}
@end
