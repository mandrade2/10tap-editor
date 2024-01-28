#import "TenTapViewImpl.h"
#import "Utils.h"
#import <WebKit/WebKit.h>
#import <React/RCTUIManager.h>

@interface HelperViewTemp : UIView

@property (nullable, nonatomic, readwrite, strong) UIInputViewController *inputViewController;
@property (nullable, readwrite, strong) UIView *inputAccessoryView;
@property (nonatomic) BOOL keepInSuperviewOnResign;

@end

@implementation HelperViewTemp

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

@end

@implementation TenTapViewImpl

- (instancetype)init {
    self = [super init];
    if (self) {
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

- (WKWebView *)findFirstWKWebViewInView:(UIView *)view {
    if ([view isKindOfClass:[WKWebView class]]) {
        return view;
    }
    
    NSLog(@"NOT HERE %@", view.class);

    for (UIView *subview in view.subviews) {
        UIView *webView = [self findFirstWKWebViewInView:subview];
        if (webView != nil) {
            return webView;
        }
    }

    return nil;
}

- (void)setText:(NSString *)text {
    _text = text;
    self.textField.text = text;
}

- (void)setPlaceholder:(NSString *)placeholder {
    _placeholder = placeholder;
    self.textField.placeholder = placeholder;
    [self searchForWebview];
}

- (void)setInputTag:(NSNumber *)inputTag {
    _inputTag = inputTag;
    if(self.bridge == nil)
    {
        NSLog(@"No bridge");
        return;
    }
    
    // Get input field from tag (react ref)
    UIView* inputField = [self.bridge.uiManager viewForReactTag:inputTag];
    if(inputField != nil) {
        // Create keyboard
        UIView *customKeyboard = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 300)];
        customKeyboard.backgroundColor = [UIColor lightGrayColor];
        UIInputViewController *inputController = [[UIInputViewController alloc] init];
        inputController.inputView = customKeyboard;
//        [inputController.inputView addSubview:customKeyboard];
        
        // Create helper view
        HelperViewTemp *helperView = [[HelperViewTemp alloc] initWithFrame:CGRectZero];
        NSLog(@"Found input view");
        // Don't know why this is done
        UIView *firstResponder = [self getFirstResponder:inputField];
        helperView.inputAccessoryView = firstResponder.inputAccessoryView;


        helperView.backgroundColor = [UIColor clearColor];

        [inputField.superview addSubview:helperView];
        [inputField.superview sendSubviewToBack:helperView];

        helperView.inputViewController = inputController;
        [helperView reloadInputViews];
        [helperView becomeFirstResponder];
        
        inputField.backgroundColor = [UIColor redColor];
        helperView.backgroundColor = [UIColor greenColor];
        return;
    }
    NSLog(@"No input field");
}

- (void)didMoveToSuperview {
    [super didMoveToSuperview];
    [self searchForWebview];
}

- (void)searchForWebview {
    if (self.superview) {
        // The view has been added to a superview
        NSLog(@"TenTapViewImpl has been mounted.");

        // Example: Finding the first WebView after the view is mounted
        WKWebView *webView = [self findFirstWKWebViewInView:self.superview];
        if (webView) {
            NSLog(@"Found a WebView: %@");
        } else {
            NSLog(@"No WebView found in the superview.");
        }
    }
}

-(UIView*)getFirstResponder:(UIView*)view
{
    if (view == nil || [view isFirstResponder])
    {
        return view;
    }
    
    for (UIView *subview in view.subviews)
    {
        UIView *firstResponder = [self getFirstResponder:subview];
        if(firstResponder != nil)
        {
            return firstResponder;
        }
    }
    return nil;
}

@end
