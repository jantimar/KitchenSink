//
//  KitchenSinkViewController.m
//  KitchenSink
//
//  Created by Jan Timar on 10/21/13.
//  Copyright (c) 2013 Jan Timar. All rights reserved.
//

#import "KitchenSinkViewController.h"
#import "AskerViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "CMMotionManager+Shared.h"

@interface KitchenSinkViewController () <UIActionSheetDelegate,UIImagePickerControllerDelegate, UINavigationControllerDelegate,UIPopoverControllerDelegate>

@property (strong, nonatomic) IBOutlet UIView *kitchenSink;

@property (weak,nonatomic) NSTimer *drainTimer;

@property (weak,nonatomic) UIActionSheet *sinkControlActionSheet;

@property (nonatomic,strong) UIPopoverController *imagePickerPopover;

@end

@implementation KitchenSinkViewController

#define MOVE_DURATION 3.0
#define DRAIN_DURATION 3.0
#define DRAIN_DELAY 1.0
#define DISH_CLEANING_INTERVAL 2.0

// definovanie si pre action sheet okno
#define SINK_CONTROL @"Sink Controls"
#define SINK_CONTROL_STOP_DRAIN @"Stopper Drain"
#define SINK_CONTROL_UNSTOP_DRAIN @"Unstopper Drain"
#define SINK_CONTROL_CANCLE @"Cancle"
#define SINK_CONTROL_EMPTY @"Empty Sink"

#define MAX_IMAGE_WIDTH 200

#define DRIFT_HZ 10
#define DRIFT_RATE 10

// pre zobrazenie action sheet okna
- (IBAction)controlSink:(UIBarButtonItem *)sender {
    
    if(!self.sinkControlActionSheet)
    {
        NSString *drainButton = self.drainTimer ? SINK_CONTROL_STOP_DRAIN : SINK_CONTROL_UNSTOP_DRAIN;
        
        UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:SINK_CONTROL
                                                                delegate:self
                                                       cancelButtonTitle:SINK_CONTROL_CANCLE
                                                  destructiveButtonTitle:SINK_CONTROL_EMPTY
                                                       otherButtonTitles:drainButton,nil];
        [actionSheet showFromBarButtonItem:sender animated:YES];
        self.sinkControlActionSheet = actionSheet; // pre to aby sa nedalo na button dokola klikat
    }
}

// delegat pre reakciu na stlacenie buttonu
-(void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == actionSheet.destructiveButtonIndex){
        [self.kitchenSink.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    } else {
        NSString *choice = [actionSheet buttonTitleAtIndex:buttonIndex];
        if([choice isEqualToString:SINK_CONTROL_STOP_DRAIN]){
            [self stopDrainTimer];
        } else if ([choice isEqualToString:SINK_CONTROL_UNSTOP_DRAIN]){
            [self startDrainTimer];
        }
    }
}

- (IBAction)addFoodPhoto:(UIBarButtonItem *)sender
{
    [self presentImagePickerViewController:UIImagePickerControllerSourceTypePhotoLibrary sender:sender];
}

- (IBAction)takeFoodPhoto:(UIBarButtonItem *)sender
{
    [self presentImagePickerViewController:UIImagePickerControllerSourceTypeCamera sender:sender];
}

-(void)presentImagePickerViewController:(UIImagePickerControllerSourceType)sourceType sender:(UIBarButtonItem *)sender
{
    if(!self.imagePickerPopover && [UIImagePickerController isSourceTypeAvailable:sourceType]){
        NSArray *avaliableMediaTypes = [UIImagePickerController availableMediaTypesForSourceType:sourceType];
        if([avaliableMediaTypes containsObject:(NSString *)kUTTypeImage]){
            UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
            imagePickerController.sourceType = sourceType;
            imagePickerController.mediaTypes = @[(NSString *)kUTTypeImage];
            imagePickerController.allowsEditing = YES;
            imagePickerController.delegate = self;
            if((sourceType != UIImagePickerControllerSourceTypeCamera && (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad))){
                self.imagePickerPopover = [[UIPopoverController alloc] initWithContentViewController:imagePickerController];
                [self.imagePickerPopover presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
                self.imagePickerPopover.delegate = self;
            } else {
                [self presentViewController:imagePickerController animated:YES completion:nil];
            }
        }
    }
}

-(void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    self.imagePickerPopover = nil;
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = info[UIImagePickerControllerEditedImage];
    if(!image) image = info[UIImagePickerControllerOriginalImage];
    if(image){
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        CGRect frame = imageView.frame;
        if(frame.size.width > MAX_IMAGE_WIDTH){
            frame.size.height = (frame.size.height / frame.size.width) * MAX_IMAGE_WIDTH;
            frame.size.width = MAX_IMAGE_WIDTH;
        }
        imageView.frame = frame;
        [self setRandomLocationForView:imageView];
        [self.kitchenSink addSubview:imageView];
    }
    if(self.imagePickerPopover){
        [self.imagePickerPopover dismissPopoverAnimated:YES];
        self.imagePickerPopover = nil;
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

-(void)cleanDish
{
    if(self.kitchenSink.window)
    {
        [self addFood:nil];
        [self performSelector:@selector(cleanDish) withObject:nil afterDelay:DISH_CLEANING_INTERVAL];
    }
}

// pridanie jedla na plochu view
-(void)addFood:(NSString *)food
{
    // vytvorenie noveho text label
    UILabel *foodLabel = [[UILabel alloc] init];
    
    
#define BLUE_FOOD @"Jello"
#define GREEN_FOOD @"Broccoli"
#define ORANGE_FOOD @"Carrot"
#define RED_FOOD @"Beet"
#define PURPLE_FOOD @"Eggplant"
#define BROWN_FOOD @"Potato Peels"
    
    static NSDictionary *foods = nil;
    
    if(!foods) foods = @{ BLUE_FOOD : [UIColor blackColor],
                          GREEN_FOOD : [UIColor greenColor],
                          ORANGE_FOOD : [UIColor orangeColor],
                          RED_FOOD : [UIColor redColor],
                          PURPLE_FOOD : [UIColor purpleColor],
                          BROWN_FOOD : [UIColor brownColor]
                          };
    
    if(![food length])
    {
        food = [[foods allKeys] objectAtIndex:arc4random()%[foods count]];
        foodLabel.textColor = [foods objectForKey:food];
    }
    
    
    //nastavenie mu text
    foodLabel.text = food;
    // nastavenie velkosti jeho fontu
    foodLabel.font = [UIFont systemFontOfSize:46];
    // nastavenie jeho pozadia na priesvitne
    foodLabel.backgroundColor = [UIColor clearColor];
    
    [foodLabel sizeToFit];
    // nastavenie mu nahodnej pozicie v kitchenSink viewe
    [self setRandomLocationForView:foodLabel];
    // pridanie ho do kitchen sink
    [self.kitchenSink addSubview:foodLabel];
    
    // hned po pridani sa spusti animacia drain na vsetkych jedlach
    //[self drain];
}

#pragma mark - drain

-(void)startDrainTimer
{
    // prida do vykonania po case DRAIN_DURATION/3 vykonanie funkcie drain:
    self.drainTimer = [NSTimer scheduledTimerWithTimeInterval:DRAIN_DURATION/3 target:self selector:@selector(drain:) userInfo:nil repeats:YES];
}

//funkcia ktora sa neodskorene spusti
-(void)drain:(NSTimer *)timer
{
    [self drain];
}

// prerusenie timeru
-(void)stopDrainTimer
{
    [self.drainTimer invalidate];
    self.drainTimer = nil;
}

#pragma mark - drift

-(void)startDrift
{
    CMMotionManager *motionManager = [CMMotionManager sharedMotionManager];
    if([motionManager isAccelerometerAvailable]){
        [motionManager setAccelerometerUpdateInterval:1/DRIFT_HZ];
        [motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue mainQueue]
                                            withHandler:^(CMAccelerometerData *accelerometerData, NSError *error) {
                                                for(UIView *view in self.kitchenSink.subviews){
                                                    CGPoint center = view.center;
                                                    center.x += accelerometerData.acceleration.x * DRIFT_RATE;
                                                    center.y -= accelerometerData.acceleration.y * DRIFT_RATE;
                                                    view.center = center;
                                                    if(CGRectContainsRect(self.kitchenSink.bounds, view.frame) && !CGRectIntersectsRect(self.kitchenSink.bounds, view.frame)){
                                                        [view removeFromSuperview];
                                                    }
                                                }
                                            }];
    }
}

-(void)stopDrift
{
    [[CMMotionManager sharedMotionManager] stopAccelerometerUpdates];
}

// po objaveni sa view aby sa timer spustil
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self startDrainTimer];
    [self cleanDish];
    [self startDrift];
}

// po dostteni sa z view aby sa timer zastavil
-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self stopDrainTimer];
    [self stopDrift];
}


-(void)setRandomLocationForView:(UIView *)view
{
    CGRect sinkBounds = CGRectInset(self.kitchenSink.bounds, view.frame.size.width/2, view.frame.size.height/2);
    CGFloat horizontal = arc4random() % (int)sinkBounds.size.width + view.frame.size.width/2;
    CGFloat vertical = arc4random() % (int)sinkBounds.size.height + view.frame.size.height/2;
    view.center = CGPointMake(horizontal, vertical);
}

-(void)drain
{
    for (UIView * view in self.kitchenSink.subviews)
    {
        CGAffineTransform transform = view.transform;
        if(CGAffineTransformIsIdentity(transform))
        {
            [UIView animateWithDuration:DRAIN_DURATION/3 delay:DRAIN_DELAY options:UIViewAnimationOptionCurveLinear animations:^{
                view.transform = CGAffineTransformRotate(CGAffineTransformScale(transform, 0.7, 0.7), 2*M_PI/3);
            } completion:^(BOOL finished) {
                if(finished)
                {
                    [UIView animateWithDuration:DRAIN_DURATION/3 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
                        view.transform = CGAffineTransformRotate(CGAffineTransformScale(transform, 0.4, 0.4), -2*M_PI/3);
                    } completion:^(BOOL finished) {
                        if(finished)
                        {
                            [UIView animateWithDuration:DRAIN_DURATION/3 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
                                view.transform = CGAffineTransformScale(transform, 0.1, 0.1);
                            } completion:^(BOOL finished) {
                                if(finished)
                                {
                                    [view removeFromSuperview];
                                }
                            }];
                        }
                    }];
                }
            }];
        }
    }
}


- (IBAction)tap:(UITapGestureRecognizer *)sender {
    CGPoint tapLocation = [sender locationInView:self.kitchenSink];
    for(UIView *view in self.kitchenSink.subviews)
    {
        // zisti ci je v tom kliknute ak ano moze vykonat presun
        if(CGRectContainsPoint(view.frame, tapLocation))
        {
            // animacia trvajuca MOVE_duration pocas ktorej sa zmeni poloha textu
            //[UIView animateWithDuration:MOVE_DURATION animations:^{
            //    [self setRandomLocationForView:view];
            //}];
            
            //nova animacia zmensi ho ale po 3 sekundach sa nastavi spat na povodnu velkost
            [UIView animateWithDuration:MOVE_DURATION delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
                [self setRandomLocationForView:view];
                view.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.99, 0.99);
            } completion:^(BOOL finished) {
                if(finished) view.transform = CGAffineTransformIdentity;
            }];
        }
    }
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"KitchenSinkVC preperForSegue with identifie: %@",segue.identifier);
    if([segue.identifier isEqualToString:@"Ask"])
    {
        //if([segue.destinationViewController isEqual:[AskViewController class]])
        //{
        AskerViewController *askerViewController = (AskerViewController *)segue.destinationViewController;
        [askerViewController setQuestion:@"What food add to sink"];
        //}
    }
}


-(IBAction)cancelAsk:(UIStoryboardSegue *)segue
{
    NSLog(@"KitchenSinkVC cancelAsk");
    
}

-(IBAction)doneAsk:(UIStoryboardSegue *)segue
{
    AskerViewController *askerViewController = segue.sourceViewController;
    NSLog(@"KitchenSinkVC doneAsk with answare %@",askerViewController.answare);
    [self addFood:askerViewController.answare];
}


@end
