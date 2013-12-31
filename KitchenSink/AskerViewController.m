//
//  AskerViewController.m
//  KitchenSink
//
//  Created by Jan Timar on 10/21/13.
//  Copyright (c) 2013 Jan Timar. All rights reserved.
//

#import "AskerViewController.h"

@interface AskerViewController ()

@property (weak, nonatomic) IBOutlet UILabel *questionLabel;

@property (weak, nonatomic) IBOutlet UITextField *answareTextField;

@end

@implementation AskerViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.questionLabel.text = self.question;
    self.answareTextField.text = nil;
    [self.answareTextField becomeFirstResponder];
}

-(NSString *)answare
{
    return self.answareTextField.text;
}

-(void)setQuestion:(NSString *)question
{
    _question = question;
    self.questionLabel.text = question;
}

@end
