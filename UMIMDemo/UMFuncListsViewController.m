//
//  UMFuncListsViewController.m
//  UMIMDemo
//
//  Created by 石乐 on 16/1/12.
//  Copyright © 2016年 石乐. All rights reserved.
//

#import "UMFuncListsViewController.h"
#import "SPKitExample.h"
#import "SPUtil.h"
@interface UMFuncListsViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic,strong)  NSArray *funclistarray;
@end

@implementation UMFuncListsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableview=[[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    self.tableview.dataSource=self;
    self.tableview.delegate=self;
    self.funclistarray=@[@"获取会话列表",@"打开单聊页面",@"打开群聊页面",@"修改会话列表页面的导航栏标题"];
    [self.view addSubview:self.tableview];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.funclistarray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ID=@"cell";
    
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
        //cell的颜色
        //cell.backgroundColor=SLRandomColor;
    }
    
    //设置cell的文本信息
    cell.textLabel.text=self.funclistarray[(long)indexPath.row];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
            //获取会话列表
        case 0:
        {
            __weak typeof(self) weakSelf = self;
            YWConversationListViewController *conversationListController = [[SPKitExample sharedInstance] exampleMakeConversationListControllerWithSelectItemBlock:^(YWConversation *aConversation) {
                if ([aConversation isKindOfClass:[YWCustomConversation class]]) {
                    YWCustomConversation *customConversation = (YWCustomConversation *)aConversation;
                    [customConversation markConversationAsRead];
                } else {
                    [[SPKitExample sharedInstance] exampleOpenConversationViewControllerWithConversation:aConversation fromNavigationController:weakSelf.navigationController];
                }
            }];
            
            [self.navigationController pushViewController:conversationListController animated:YES];
        }
            break;
            //打开单聊页面
        case 1:
        {
            __weak typeof(self) weakSelf = self;
            /// 创建Person对象
            YWPerson *person = [[YWPerson alloc] initWithPersonId:@"visitor345"];
            [[SPKitExample sharedInstance] exampleOpenConversationViewControllerWithPerson:person fromNavigationController:weakSelf.navigationController];
        }
            break;
            //打开群聊页面，现在是打开账号的群列表中的第一个群
        case 2:
        {
            __weak typeof(self) weakSelf = self;
            NSArray *tribes = [self.ywTribeService fetchAllTribes];
            YWTribe *tribe = tribes[0];
            [[SPKitExample sharedInstance] exampleOpenConversationViewControllerWithTribe:tribe fromNavigationController:weakSelf.navigationController];
        }
            break;
            //修改会话列表页面的导航栏标题
        case 3:
        {
            __weak typeof(self) weakSelf = self;
            YWConversationListViewController *conversationListController = [[SPKitExample sharedInstance] exampleMakeConversationListControllerWithSelectItemBlock:^(YWConversation *aConversation) {
                if ([aConversation isKindOfClass:[YWCustomConversation class]]) {
                    YWCustomConversation *customConversation = (YWCustomConversation *)aConversation;
                    [customConversation markConversationAsRead];
                } else {
                    [[SPKitExample sharedInstance] exampleOpenConversationViewControllerWithConversation:aConversation fromNavigationController:weakSelf.navigationController];
                }
            }];
            __weak typeof(conversationListController) weakController = conversationListController;
            [conversationListController setViewDidLoadBlock:^{
                [weakController.navigationItem setTitle:@"消息"];
            }];
            [self.navigationController pushViewController:conversationListController animated:YES];
        }
            break;
        default:
            break;
    }
   
}

- (YWIMCore *)ywIMCore {
    return [SPKitExample sharedInstance].ywIMKit.IMCore;
}

- (id<IYWTribeService>)ywTribeService {
    return [[self ywIMCore] getTribeService];
}
@end
