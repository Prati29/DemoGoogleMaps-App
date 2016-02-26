//
//  DirectionCell.h
//  LocationOnMap
//
//  Created by Admin on 24/02/16.
//  Copyright © 2016 ITC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DirectionCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *directionLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@end
