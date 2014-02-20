//
//  DLTPostTableViewCell.h
//  Delecteddit
//
//  Created by Antonin Lacombe on 19/02/2014.
//  Copyright (c) 2014 Antonin Lacombe. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DLTPostTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *thumbnailImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *scoreLabel;
@property (weak, nonatomic) IBOutlet UILabel *commentNumberLabel;

@end
