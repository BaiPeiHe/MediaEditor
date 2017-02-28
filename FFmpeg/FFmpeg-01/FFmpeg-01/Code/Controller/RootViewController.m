//
//  RootViewController.m
//  FFmpeg-01
//
//  Created by 白鹤 on 2017/2/28.
//  Copyright © 2017年 白鹤. All rights reserved.
//

#import "RootViewController.h"
#include <libavcodec/avcodec.h>

@interface RootViewController ()

@end

@implementation RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor brownColor];
    
    printf("%s",avcodec_configuration());
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
