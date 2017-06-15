//
//  ViewController.m
//  TryCML
//
//  Created by YangWu on 15/06/2017.
//  Copyright © 2017 Yang Wu. All rights reserved.
//

#import "ViewController.h"
#import "SceneImageAnalyzer.h"
@import MobileCoreServices;

@interface ViewController ()  <UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UITextView *allPossibleView;
@property (weak, nonatomic) IBOutlet UILabel *mostLikelyLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@property (strong, nonatomic) SceneImageAnalyzer * analyzer;
@property (strong, nonatomic) UIImagePickerController * picker;
@end

@implementation ViewController
- (void) navigationController: (UINavigationController *) nav  willShowViewController: (UIViewController *) vc animated: (BOOL) animated {
  if (self.picker.sourceType == UIImagePickerControllerSourceTypePhotoLibrary) {
    UIBarButtonItem* button = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(showCamera:)];
    vc.navigationItem.leftBarButtonItems = [NSArray arrayWithObject:button];
    vc.navigationController.navigationBarHidden = NO; // important
  } else {
    UIBarButtonItem* button = [[UIBarButtonItem alloc] initWithTitle:@"Library" style:UIBarButtonItemStylePlain target:self action:@selector(showLibrary:)];
    vc.navigationItem.leftBarButtonItems = [NSArray arrayWithObject:button];
    vc.navigationItem.title = @"Take Photo";
    vc.navigationController.navigationBarHidden = NO; // important
  }
}

- (void) showCamera: (id) sender {
  self.picker.sourceType = UIImagePickerControllerSourceTypeCamera;
}

- (void) showLibrary: (id) sender {
  self.picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
}

- (IBAction)pickupImageAndGo:(id)sender {
  self.picker = [[UIImagePickerController alloc] init];
  if ( [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
    self.picker.sourceType |= UIImagePickerControllerSourceTypeCamera;
    self.picker.showsCameraControls = YES;
  } else if ( [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
    self.picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
  } else if ( [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum]) {
    self.picker.sourceType |= UIImagePickerControllerSourceTypeSavedPhotosAlbum;
  }

  self.picker.mediaTypes = @[(__bridge NSString*)kUTTypeImage]; //[UIImagePickerController availableMediaTypesForSourceType:picker.sourceType];
  self.picker.allowsEditing = NO;

  self.picker.delegate = self;

  [self showViewController:self.picker sender:self];
}

#pragma mark -- UIImagePickerController --

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
  [picker dismissViewControllerAnimated:NO completion:^{

    NSString * type = info[UIImagePickerControllerMediaType];
    if ( [type isEqualToString:(__bridge NSString*)kUTTypeImage] ) {
      self.imageView.image = info[UIImagePickerControllerOriginalImage];
      [self analyzeIt];
    }

  }];
}

- (void) analyzeIt {
  NSMutableString * msg = [NSMutableString new];
  NSMutableDictionary* all = [NSMutableDictionary new];
  
  NSString * label = [self.analyzer analyzeImage:self.imageView.image allPossible:all];

  [all enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSNumber * _Nonnull value, BOOL * _Nonnull stop) {
    [msg appendFormat:@"%@  -  %.02f%%\n", key, value.floatValue*100];
  }];
  self.allPossibleView.text = msg;
  self.mostLikelyLabel.text = label;
}

#pragma mark -- lifecycle --

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view, typically from a nib.
  NSURL * modelUrl = [[NSBundle mainBundle] URLForResource:@"GoogLeNetPlaces" withExtension:@"mlmodelc"];
  self.analyzer = [[SceneImageAnalyzer alloc] initWithUrl:modelUrl];
  [self analyzeIt];
}


- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}


@end
