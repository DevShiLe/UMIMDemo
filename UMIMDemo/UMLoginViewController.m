//
//  UMLoginViewController.m
//  UMIMDemo
//
//  Created by 石乐 on 16/1/12.
//  Copyright © 2016年 石乐. All rights reserved.
//

#import "UMLoginViewController.h"
#import "SPKitExample.h"
#import "SPUtil.h"
#import "UMFuncListsViewController.h"
@interface UMLoginViewController ()
<UIActionSheetDelegate,UISplitViewControllerDelegate>

@property (nonatomic, weak) UINavigationController *weakDetailNavigationController;


@property (strong , nonatomic)UIView *viewOperator;
@property (strong , nonatomic)UIView *viewInput;

@property (strong , nonatomic)UITextField *textFieldUserID;
@property (strong , nonatomic)UITextField *textFieldPassword;
@property (strong , nonatomic)UIButton *loginbutton;

/**
 *  获取随机游客账号
 */
- (void)_getVisitorUserID:(NSString **)aGetUserID password:(NSString **)aGetPassword;

@end

@implementation UMLoginViewController

#pragma mark - public

+ (void)getLastUserID:(NSString *__autoreleasing *)aUserID lastPassword:(NSString *__autoreleasing *)aPassword
{
    if (aUserID) {
        *aUserID = [self lastUserID];
    }
    
    if (aPassword) {
        *aPassword = [self lastPassword];
    }
}

#pragma mark - private

- (void)_getVisitorUserID:(NSString *__autoreleasing *)aGetUserID password:(NSString *__autoreleasing *)aGetPassword
{
    if (aGetUserID) {
        *aGetUserID = [NSString stringWithFormat:@"visitor%d", arc4random()%1000+1];
    }
    
    if (aGetPassword) {
        *aGetPassword = [NSString stringWithFormat:@"taobao1234"];
    }
}

- (void)_presentSplitControllerAnimated:(BOOL)aAnimated
{
    if (self.navigationController.topViewController != self) {
        /// 已经进入主页面
        return;
    }
    
    UISplitViewController *splitController = [[UISplitViewController alloc] init];
    
    if ([splitController respondsToSelector:@selector(setPreferredDisplayMode:)]) {
        [splitController setPreferredDisplayMode:UISplitViewControllerDisplayModeAllVisible];
    }
    
    /// 各个页面
    
    UINavigationController *masterController = nil, *detailController = nil;
    
    {
        /// 消息列表页面
        
        UIViewController *viewController = [[UIViewController alloc] init];
        [viewController.view setBackgroundColor:[UIColor whiteColor]];
        UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:viewController];
        
        detailController = nvc;
    }
    
}

- (void)_addNotifications
{
    /// 监听键盘事件
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onKeyboardWillShowNotification:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onKeyboardWillHideNotification:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)_pushMainControllerAnimated:(BOOL)aAnimated
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [self _presentSplitControllerAnimated:aAnimated];
    } else {
        if (self.navigationController.topViewController != self) {
            /// 已经进入主页面
            return;
        }
        UMFuncListsViewController *tabController = [[UMFuncListsViewController alloc] init];
        
        [self.navigationController pushViewController:tabController animated:aAnimated];
    }
}

- (void)_tryLogin
{
    __weak typeof(self) weakSelf = self;
    
    [[SPUtil sharedInstance] setWaitingIndicatorShown:YES withKey:self.description];
    
    //这里先进行应用的登录
    
    //应用登陆成功后，登录IMSDK
    [[SPKitExample sharedInstance] callThisAfterISVAccountLoginSuccessWithYWLoginId:self.textFieldUserID.text
                                                                           passWord:self.textFieldPassword.text
                                                                    preloginedBlock:^{
                                                                        [[SPUtil sharedInstance] setWaitingIndicatorShown:NO withKey:weakSelf.description];
                                                                        [weakSelf _pushMainControllerAnimated:YES];
                                                                    } successBlock:^{
                                                                        
                                                                        //  到这里已经完成SDK接入并登录成功，你可以通过exampleMakeConversationListControllerWithSelectItemBlock获得会话列表
                                                                        [[SPUtil sharedInstance] setWaitingIndicatorShown:NO withKey:weakSelf.description];
                                                                        
                                                                        [weakSelf _pushMainControllerAnimated:YES];
#if DEBUG
                                                                        // 自定义轨迹参数均为透传
                                                                        //                                                                        [YWExtensionServiceFromProtocol(IYWExtensionForCustomerService) updateExtraInfoWithExtraUI:@"透传内容" andExtraParam:@"透传内容"];
#endif
                                                                    } failedBlock:^(NSError *aError) {
                                                                        [[SPUtil sharedInstance] setWaitingIndicatorShown:NO withKey:weakSelf.description];
                                                                        
                                                                        if (aError.code == YWLoginErrorCodePasswordError || aError.code == YWLoginErrorCodePasswordInvalid || aError.code == YWLoginErrorCodeUserNotExsit) {
                                                                            
                                                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                                                UIActionSheet *as = [[UIActionSheet alloc] initWithTitle:@"登录失败, 可以使用游客登录。\n（如在调试，请确认AppKey、帐号、密码是否正确。）" delegate:weakSelf cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"游客登录", nil];
                                                                                [as showInView:weakSelf.view];
                                                                            });
                                                                        }
                                                                        
                                                                    }];
}

#pragma mark - properties

+ (NSString *)lastUserID
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"lastUserID"];
}

+ (void)setLastUserID:(NSString *)lastUserID
{
    [[NSUserDefaults standardUserDefaults] setObject:lastUserID forKey:@"lastUserID"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSString *)lastPassword
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"lastPassword"];
}

+ (void)setLastPassword:(NSString *)lastPassword
{
    [[NSUserDefaults standardUserDefaults] setObject:lastPassword forKey:@"lastPassword"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


#pragma mark - life circle
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor=[UIColor whiteColor];
    self.viewOperator=[[UIView alloc]initWithFrame:CGRectMake(0, 60, self.view.frame.size.width, 300)];
    self.viewInput=[[UIView alloc]initWithFrame:CGRectMake(0, 60, self.view.frame.size.width, 100)];
    
    self.textFieldUserID=[[UITextField alloc]initWithFrame:CGRectMake(80, 0, self.view.frame.size.width-60, 50)];
    self.textFieldPassword=[[UITextField alloc]initWithFrame:CGRectMake(80, 50, self.view.frame.size.width-60, 50)];
    [self.viewOperator addSubview:self.viewInput];
    [self.viewInput addSubview:self.textFieldUserID];
    [self.viewInput addSubview:self.textFieldPassword];
    [self.view addSubview:self.viewOperator];
    self.loginbutton=[UIButton buttonWithType:UIButtonTypeCustom];
    self.loginbutton.frame=CGRectMake(20, self.viewOperator.frame.size.height-50, self.viewOperator.frame.size.width-40, 50);
    [self.view addSubview:self.loginbutton];
    [self.loginbutton addTarget:self action:@selector(actionLogin:) forControlEvents:UIControlEventTouchUpInside];
    [self.loginbutton setTitle:@"登录" forState:UIControlStateNormal];
    [self.loginbutton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    
    [self setTitle:@"Login"];
    
    BOOL shouldAutoLogin = YES;
    NSString *userID = [UMLoginViewController lastUserID];
    NSString *password = nil;
    if (userID) {
        password = [UMLoginViewController lastPassword];
    }
    else {
        shouldAutoLogin = NO;
        [self _getVisitorUserID:&userID password:&password];
    }
    
    [self.textFieldUserID setText:userID];
    [self.textFieldPassword setText:password];
    
    [self.viewInput.layer setBorderWidth:0.5f];
    [self.viewInput.layer setBorderColor:[UIColor colorWithRed:0.f green:180.f/255.f blue:255.f/255.f alpha:1.f].CGColor];
    
    [self _addNotifications];
    
    
    if (shouldAutoLogin && self.textFieldUserID.text.length > 0 && self.textFieldPassword.text.length > 0) {
        [self _tryLogin];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - actions

- (void)actionLogin:(id)sender
{
    [self.view endEditing:YES];
    
    [UMLoginViewController setLastUserID:self.textFieldUserID.text];
    [UMLoginViewController setLastPassword:self.textFieldPassword.text];
    
    [self _tryLogin];
}

- (void)actionBackground:(id)sender {
    [self.view endEditing:YES];
}

- (void)actionLogoutiPad:(id)sender
{
    [[SPKitExample sharedInstance] callThisBeforeISVAccountLogout];
    [self.presentedViewController dismissViewControllerAnimated:YES completion:NULL];
}

- (void)actionCloseiPad:(id)sender
{
    [self.weakDetailNavigationController popToRootViewControllerAnimated:NO];
}

- (void)actionVisitor:(id)sender {
    NSString *userID = nil, *password = nil;
    [self _getVisitorUserID:&userID password:&password];
    
    [self.textFieldUserID setText:userID];
    [self.textFieldPassword setText:password];
    
    [self actionLogin:nil];
}


#pragma mark - notifications

static NSValue *sOldCenter = nil;

- (void)onKeyboardWillShowNotification:(NSNotification *)aNote
{
    if (sOldCenter == nil) {
        sOldCenter = [NSValue valueWithCGPoint:self.viewOperator.center];
    }
    
    CGRect keyboardFrame = [aNote.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    CGPoint toPoint = CGPointMake(self.view.center.x, self.view.center.y - keyboardFrame.size.height + 30);
    
    [UIView animateWithDuration:0.25f animations:^{
        [self.viewOperator setCenter:toPoint];
    }];
}

- (void)onKeyboardWillHideNotification:(NSNotification *)aNote
{
    if (sOldCenter) {
        [UIView animateWithDuration:0.25f animations:^{
            [self.viewOperator setCenter:sOldCenter.CGPointValue];
        }];
    }
}

#pragma mark - UISplitViewController delegate

- (BOOL)splitViewController:(UISplitViewController *)svc shouldHideViewController:(UIViewController *)vc inOrientation:(UIInterfaceOrientation)orientation  NS_DEPRECATED_IOS(5_0, 8_0, "Use preferredDisplayMode instead")
{
    return NO;
}

#pragma mark - UIActionSheet delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.firstOtherButtonIndex) {
        [self actionVisitor:nil];
    }
}
@end
