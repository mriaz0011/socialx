//
//

#import <UIKit/UIKit.h>
#import "FXBlurView.h"

#pragma mark ControlPointView interface

@interface ControlPointView : UIView {
    CGFloat red, green, blue, alpha;
}

@property (nonatomic, retain) UIColor* color;

@end

#pragma mark ShadeView interface

@interface ShadeView : UIView {
    CGFloat cropBorderRed, cropBorderGreen, cropBorderBlue, cropBorderAlpha;
    CGRect cropArea;
    CGFloat shadeAlpha;
}

@property (nonatomic, retain) UIColor* cropBorderColor;
@property (nonatomic) CGRect cropArea;
@property (nonatomic) CGFloat shadeAlpha;
@property (nonatomic, strong) UIImageView *blurredImageView;

@end

CGRect SquareCGRectAtCenter(CGFloat centerX, CGFloat centerY, CGFloat size);

UIView* dragView;
typedef struct {
    CGPoint dragStart;
    CGPoint topLeftCenter;
    CGPoint bottomLeftCenter;
    CGPoint bottomRightCenter;
    CGPoint topRightCenter;
    CGPoint clearAreaCenter;
} DragPoint;

// Used when working with multiple dragPoints
typedef struct {
    DragPoint mainPoint;
    DragPoint optionalPoint;
    NSUInteger lastCount;
} MultiDragPoint;

#pragma mark ImageCropView interface

@interface ImageCropView : UIView {
    UIImageView* imageView;
    CGRect imageFrameInView;
    CGFloat imageScale;
    
    CGFloat controlPointSize;
    ControlPointView* topLeftPoint;
    ControlPointView* bottomLeftPoint;
    ControlPointView* bottomRightPoint;
    ControlPointView* topRightPoint;
    NSArray *PointsArray;
    UIColor* controlColor;
    
    UIView* cropAreaView;
    DragPoint dragPoint;
    MultiDragPoint multiDragPoint;
    
    UIView* dragViewOne;
    UIView* dragViewTwo;
}
- (id)initWithFrame:(CGRect)frame blurOn:(BOOL)blurOn;
- (void)setImage:(UIImage*)image;

@property (nonatomic) CGFloat controlPointSize;
@property (nonatomic, retain) UIImage* image;
@property (nonatomic) CGRect cropAreaInView;
@property (nonatomic) CGRect cropAreaInImage;
@property (nonatomic, readonly) CGFloat imageScale;
@property (nonatomic) CGFloat maskAlpha;
@property (nonatomic, retain) UIColor* controlColor;
@property (nonatomic, strong) ShadeView* shadeView;
@property (nonatomic) BOOL blurred;

@end

@interface iconImageView : UIImageView {
}
@end

#pragma mark ImageCropViewController interface
@protocol ImageCropViewControllerDelegate <NSObject>

- (void)ImageCropViewControllerSuccess:(UIViewController* )controller didFinishCroppingImage:(UIImage *)croppedImage;
- (void)ImageCropViewControllerDidCancel:(UIViewController *)controller;

@end

@interface ImageCropViewController : UIViewController {
    ImageCropView * cropView;
    iconImageView * updateIconImageView;
    //UIActionSheet*actionSheet;UIViewController<UIActionSheetDelegate>
}
@property (nonatomic, weak) id<ImageCropViewControllerDelegate> delegate;
@property (nonatomic) BOOL blurredBackground;
@property (nonatomic) NSString* cropImageBoundryValue; //Circle, Square
@property (nonatomic, retain) UIImage* image;
@property (nonatomic, retain) iconImageView* updateIconImageView;
@property (nonatomic, retain) ImageCropView* cropView;

- (id)initWithImage:(UIImage*)image;
- (void)done;
- (void)preview;

@end

@interface UIImage (fixOrientation)

- (UIImage *)fixOrientation;

@end
