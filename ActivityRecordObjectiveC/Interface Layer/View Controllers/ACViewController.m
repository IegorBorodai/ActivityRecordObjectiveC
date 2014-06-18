//
//  ACViewController.m
//  ActivityRecordObjectiveC
//
//  Created by Iegor Borodai on 6/10/14.
//  Copyright (c) 2014 Iegor Borodai. All rights reserved.
//

#import "ACViewController.h"
#import "NCNetworkClient.h"

@interface ACViewController ()

@end

@implementation ACViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self performSelector:@selector(loadImage) withObject:nil afterDelay:1.0];
}

- (void)loadImage
{
    [NCNetworkClient downloadImageFromPath:@"https:\/\/www.localsgowild.com\/photo\/primary\/id\/67a529faddb711e39ef5441ea14ed80c?hash=eyJ0eXBlIjoibm9ybWFsIiwic2l6ZSI6IiIsImZvclVzZXJJZCI6ImMwMTA2ZTYwZTU0NDExZTI5ZGYyOTBiMTFjMDVmMGI5IiwidXBkYXRlZE9uIjoiMDAwMC0wMC0wMCAwMDowMDowMCJ9&updatedOn=1400327057" success:^(UIImage *image) {
        self.testImageView.image = image;
    } failure:^(NSError *error, BOOL isCanceled) {
        NSLog([error localizedDescription]);
    } progress:nil];

//    [NCNetworkClient downloadFileFromPath:@"https:\/\/www.localsgowild.com\/photo\/primary\/id\/67a529faddb711e39ef5441ea14ed80c?hash=eyJ0eXBlIjoibm9ybWFsIiwic2l6ZSI6IiIsImZvclVzZXJJZCI6ImMwMTA2ZTYwZTU0NDExZTI5ZGYyOTBiMTFjMDVmMGI5IiwidXBkYXRlZE9uIjoiMDAwMC0wMC0wMCAwMDowMDowMCJ9&updatedOn=1400327057" toFilePath:nil success:^(NSURL *fileURL) {
//        UIImage* image = [UIImage imageWithContentsOfFile:[fileURL path]];
//        self.testImageView.image = image;
//    } failure:^(NSError *error, BOOL isCanceled) {
//        NSLog([error localizedDescription]);
//    } progress:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
