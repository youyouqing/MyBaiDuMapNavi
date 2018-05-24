//
//  ViewController.m
//  BBBB
//
//  Created by zhangmin on 2018/5/23.
//  Copyright © 2018年 zhangmin. All rights reserved.
//

#import "ViewController.h"
#import <BaiduMapAPI_Map/BMKMapComponent.h>
#import <BaiduMapAPI_Base/BMKBaseComponent.h>
#import <BaiduMapAPI_Search/BMKSearchComponent.h>
#import <BaiduMapAPI_Location/BMKLocationComponent.h>
#import "BNCoreServices.h"
@interface ViewController ()<UITextFieldDelegate,BMKLocationServiceDelegate,BMKMapViewDelegate,BNNaviRoutePlanDelegate,BNNaviUIManagerDelegate,BMKShareURLSearchDelegate,BMKGeoCodeSearchDelegate>{
    BMKMapView *_mapView;//百度地图成员变量
    BMKLocationService *_locService;//定位成员变量
    BMKUserLocation *_loaction;//记录用户位置
    BMKShareURLSearch* _shareurlsearch;//短串分享搜索对象
    BMKGeoCodeSearch* _geocodesearch;//反地理编码对象
    CLLocationCoordinate2D pt1;//保存pt
}

@end

@implementation ViewController
- (UIButton*)createButton:(NSString*)title target:(SEL)selector frame:(CGRect)frame
{
    UIButton* button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button.frame = frame;
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        [button setBackgroundColor:[UIColor whiteColor]];
    }else
    {
        [button setBackgroundColor:[UIColor clearColor]];
    }
    [button addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    UILabel* startNodeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 230, self.view.frame.size.width, 30)];
    startNodeLabel.backgroundColor = [UIColor clearColor];
    startNodeLabel.text = @"起点：国人通信大厦";
    startNodeLabel.textAlignment = NSTextAlignmentCenter;
    startNodeLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:startNodeLabel];
    
    
    UILabel* endNodeLabel = [[UILabel alloc] initWithFrame:CGRectMake(startNodeLabel.frame.origin.x, startNodeLabel.frame.origin.y+startNodeLabel.frame.size.height, self.view.frame.size.width, startNodeLabel.frame.size.height)];
    endNodeLabel.backgroundColor = [UIColor clearColor];
    endNodeLabel.text = @"终点：上海宾馆";
    endNodeLabel.textAlignment = NSTextAlignmentCenter;
    endNodeLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:endNodeLabel];
    
    CGSize buttonSize = {240,40};
    CGRect buttonFrame = {(self.view.frame.size.width-buttonSize.width)/2,40+endNodeLabel.frame.size.height+endNodeLabel.frame.origin.y,buttonSize.width,buttonSize.height};
    UIButton* externalNaviButton = [self createButton:@"外部GPS导航" target:@selector(sstartGuide)  frame:buttonFrame];
    [self.view addSubview:externalNaviButton];
    //初始化搜索服务
    _shareurlsearch = [[BMKShareURLSearch alloc]init];
    _geocodesearch = [[BMKGeoCodeSearch alloc]init];
    
    
    
    
    //判断定位服务是否开启
    if ([ CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied) {
        NSLog(@"没有开启定位");
        UIAlertController *controller=[UIAlertController alertControllerWithTitle:@"温馨提示" message:@"请去设置中打开定位服务" preferredStyle:UIAlertControllerStyleActionSheet];
        
        UIAlertAction *action=[UIAlertAction actionWithTitle:@"返回" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }];
        [controller addAction:action];
        [self presentViewController:controller animated:YES completion:nil];
    }
    
    
    //
    //配置定位信息
    _locService = [[BMKLocationService alloc]init];
    _locService.delegate = self;
    [_locService startUserLocationService];
    
    //    初始化百度地图并配置相关信息
    _mapView=[[BMKMapView alloc]initWithFrame:CGRectMake(0, 0, 300, 300-64)];
    [_mapView setZoomLevel:16];
    [_mapView setTrafficEnabled:YES];//打开实时路况
    [_mapView setBaiduHeatMapEnabled:YES];//打开百度热力图
    [_mapView setMapType:BMKMapTypeStandard];
    _mapView.showsUserLocation = YES;//显示我的位置的小圆点
    _mapView.delegate = self;
    [self.view addSubview:_mapView];
    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [self sstartGuide];
//    });


}
/**百度地图定位功能的协议方法**/
- (void)didUpdateUserHeading:(BMKUserLocation *)userLocation
{
    NSLog(@"方向");
}

/**百度地图用户位置的协议方法**/
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation
{
    if (_loaction) {
        
        return;
    }
    
    
    NSLog(@"拿到位置 lat %f,long %f",userLocation.location.coordinate.latitude,userLocation.location.coordinate.longitude);
    
    _loaction=userLocation;
    [_mapView updateLocationData:userLocation]; //更新地图上的位置
    _mapView.centerCoordinate = userLocation.location.coordinate; //更新当前位置到地图中间
    
    
    
    CLLocation *currLocation = userLocation.location;
    CLGeocoder *geocoder=[[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:currLocation
                   completionHandler:^(NSArray *placemarks,
                                       NSError *error)
     {
         CLPlacemark *placemark=[placemarks objectAtIndex:0];
         NSLog(@"placemark.addressDictionary:%@",placemark.addressDictionary);
         
         NSLog(@"%@--%@--%@--%@--%@--%@--%@--%@--%@--%@--%@--%@",placemark.name,placemark.thoroughfare,placemark.subThoroughfare,placemark.locality,placemark.subLocality,placemark.administrativeArea,placemark.subAdministrativeArea,placemark.postalCode,placemark.ISOcountryCode,placemark.country,placemark.inlandWater,placemark.ocean);
         NSString *str = placemark.addressDictionary[@"City"];
         
       
        
         
     }];
    
    [_locService stopUserLocationService];
    
}
/**气泡的协议方法 开始导航**/
-(void)sstartGuide{
    
    //节点数组
    NSMutableArray *nodesArray = [[NSMutableArray alloc]    initWithCapacity:2];
    
    //起点
    BNRoutePlanNode *startNode = [[BNRoutePlanNode alloc] init];
    startNode.pos = [[BNPosition alloc] init];
    startNode.pos.x = 113.936392;
    startNode.pos.y = 22.547148;
    startNode.pos.eType = BNCoordinate_OriginalGPS;
    [nodesArray addObject:startNode];
    
    //终点
    BNRoutePlanNode *endNode = [[BNRoutePlanNode alloc] init];
    endNode.pos = [[BNPosition alloc] init];
    endNode.pos.x = 114.076824;
    endNode.pos.y = 22.543574;
    
    endNode.pos.eType = BNCoordinate_BaiduMapSDK;
    [nodesArray addObject:endNode];
    
    NSLog(@"startNode%@----endNode-%@",startNode.pos,endNode.pos);
    //发起路径规划
    [BNCoreServices_RoutePlan startNaviRoutePlan:BNRoutePlanMode_Recommend naviNodes:nodesArray time:nil delegete:self userInfo:nil];
    
}
#pragma mark - 安静退出导航

- (void)exitNaviUI
{
    [BNCoreServices_UI exitPage:EN_BNavi_ExitTopVC animated:YES extraInfo:nil];
}

#pragma mark - BNNaviRoutePlanDelegate
//算路成功回调
-(void)routePlanDidFinished:(NSDictionary *)userInfo
{
    NSLog(@"算路成功");
    
    //路径规划成功，开始导航
    [BNCoreServices_UI showPage:BNaviUI_NormalNavi delegate:self extParams:nil];
    
    //导航中改变终点方法示例
    /*dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(15 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
     BNRoutePlanNode *endNode = [[BNRoutePlanNode alloc] init];
     endNode.pos = [[BNPosition alloc] init];
     endNode.pos.x = 114.189863;
     endNode.pos.y = 22.546236;
     endNode.pos.eType = BNCoordinate_BaiduMapSDK;
     [[BNaviModel getInstance] resetNaviEndPoint:endNode];
     });*/
}
//退出导航页面回调
- (void)onExitPage:(BNaviUIType)pageType  extraInfo:(NSDictionary*)extraInfo
{
    if (pageType == BNaviUI_NormalNavi)
    {
        NSLog(@"退出导航");
    }
    else if (pageType == BNaviUI_Declaration)
    {
        NSLog(@"退出导航声明页面");
    }
}

//算路失败回调
- (void)routePlanDidFailedWithError:(NSError *)error andUserInfo:(NSDictionary *)userInfo
{
    
    NSLog(@"%@-----%@",error,userInfo);
    
    NSLog(@"算路失败");
    switch ([error code]%10000)
    {
        case BNAVI_ROUTEPLAN_ERROR_LOCATIONFAILED:
            NSLog(@"暂时无法获取您的位置,请稍后重试");
            break;
        case BNAVI_ROUTEPLAN_ERROR_ROUTEPLANFAILED:
            NSLog(@"无法发起导航");
            break;
        case BNAVI_ROUTEPLAN_ERROR_LOCATIONSERVICECLOSED:
            NSLog(@"定位服务未开启,请到系统设置中打开定位服务。");
            break;
        case BNAVI_ROUTEPLAN_ERROR_NODESTOONEAR:
            NSLog(@"起终点距离起终点太近");
            break;
        default:
            NSLog(@"算路失败");
            break;
    }
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return NO;
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}
//算路取消
-(void)routePlanDidUserCanceled:(NSDictionary*)userInfo {
    NSLog(@"算路取消");
}
-(id)naviPresentedViewController {
    return self;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
