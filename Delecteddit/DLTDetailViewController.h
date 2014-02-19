//
//  DLTDetailViewController.h
//  Delecteddit
//
//  Created by Antonin Lacombe on 18/02/2014.
//  Copyright (c) 2014 Antonin Lacombe. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DLTDetailViewController : UIViewController

@property (strong, nonatomic) id detailItem;

@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@end
