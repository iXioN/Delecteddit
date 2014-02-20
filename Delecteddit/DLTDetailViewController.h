//
//  DLTDetailViewController.h
//  Delecteddit
//
//  Created by Antonin Lacombe on 18/02/2014.
//  Copyright (c) 2014 Antonin Lacombe. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DLTPost;
@interface DLTDetailViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextView *postSelfTextView;
@property (strong, nonatomic) DLTPost *post;
@end
