#ifndef CONTROLCMD_H
#define CONTROLCMD_H
/// <summary>
/// 云台控制的方向 5000
/// </summary>
enum PTZ_CmdType
{
    PTZ_UpLeft,     //左上
    PTZ_Up,         //上
    PTZ_UpRight,    //右上
    PTZ_Left,       //左
    PTZ_Right,      //右
    PTZ_DownLeft,   //左下
    PTZ_Down,       //下
    PTZ_DownRight,   //右下
    PTZ_SetPresetPosition,    //设置预置位
    PTZ_GetPresetPosition,    //获取预置位
    PTZ_DeletePresetPosition,    //调用预置位
    PTZ_GoPresetPosition, //转到预置位

    PTZ_CruiseStart,//开始巡航
    PTZ_CruiseContinue, //继续巡航
    PTZ_CruisePause,//开始巡航
};


enum CCD_CmdType
{
    CCD_FocusFar,   //调焦-
    CCD_FocusNear,  //调焦+
    CCD_ZoomOut,    //变倍-
    CCD_ZoomIn,     //变倍+
    CCD_ApertureOut,  //光圈-
    CCD_ApertureIn,   //光圈+

    CCD_wiper, //雨刷
    CCD_AutoFocus,      //自动调焦
};
/// <summary>
   /// 机芯指令类型 4000
   /// </summary>
enum  Ir_CmdType
{
    Ir_Confirm,        //确认
    Ir_Cancel,         //取消
    Ir_Up,             //上
    Ir_Down,           //下
    Ir_Left,           //左
    Ir_Right,          //右

    Ir_Shutter,        //打档
    Ir_ImageFree, //图像冻结
    Ir_Menu2, //菜单二
    Ir_DeviceInfo, //设备信息
    Ir_VersionInfo,//版本信息

    Ir_Colorize,       //伪彩

    Ir_AutoFocus,      //自动调焦
    Ir_FocusFar,   //调焦-
    Ir_FocusNear,  //调焦+
    Ir_ZoomOut,    //变倍-
    Ir_ZoomIn,     //变倍+
    Ir_ApertureOut,  //光圈-
    Ir_ApertureIn,   //光圈+

    Ir_wiper, //雨刷

    Ir_CancelAutoShutter,        //取消自动打挡
    Ir_AjustBackground,//背景校正

};
#endif