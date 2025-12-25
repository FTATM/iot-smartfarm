#ifndef DATADEF_H
#define DATADEF_H
#define MAC_ADDRESS_LENGTH 20  // MAC 地址长度（包括分隔符）

// 定义 IPv6 地址长度
#define IPV6_ADDRESS_LENGTH 46

#define MAX_PERIODS_PER_DAY 4  // 可根据实际需求调整
#define DAYS_IN_WEEK 7
#define MAX_URL_LEN 256
#define MAX_NAME_LEN 64
#define MAX_USERNAME_LEN 32
#define MAX_PASSWORD_LEN 32
#define MAX_TIME_LEN 32
#define MAX_POINTS 32  // 你可以根据需要扩展
#define DEFAULT_ALARM_INTERVAL 500 //默认警告时间
#define DEFAULT_ALARM_SHAKE 3
#define DEFAULT_ATOM_TRANS 1
#define DEFAULT_OPTI_TRANS 1
#define MAX_RATE_TEMP 600
#define MIN_RATE_TEMP -600
#define DEFAULT_RATE_TEMP 0

	//闪光灯持续时长，间隔闪烁，10～300
#define MIN_LIGHT_HOLD 10
#define MAX_LIGHT_HOLD 300
#define DEFAULT_LIGHT_HOLD 0

//报警抖动,单位s，1～10，默认3s
#define MIN_ALARM_SHAKE 1
#define MAX_ALARM_SHAKE 10
#define DEFAUTL_ALARM_SHAKE 3

//output_hold , range: 10 - 300.
#define MIN_OUTPUT_HOLD 10
#define MAX_OUTPUT_HOLD 300

//record_delay , range: 10 - 300.
#define MIN_RECORD_DELAY 10
#define MAX_RECORD_DELAY 300



//温度, -40～2000
#define MIN_TEMPRATURE -40
#define MAX_TEMPRATURE 2000

//温度温差,0～2000
#define MIN_DIFF_TEMP 0
#define MAX_DIFF_TEMP 2000


//距离，单位米，0.1～200.0
#define MIN_DIST 0.1
#define MAX_DIST 200


//发射率 0.1～1.0
#define MIN_EMISS 0.1
#define MAX_EMISS 1.0

#define DEFAULT_EMISS_MODE 2

//湿度 ,范围1～100
#define MIN_HUMI 1
#define MAX_HUMI 100

//预置位值
#define MIN_PRESET 1
#define MAX_PRESET 256

//版本 0 ipv4 1 ipv6
#define IP_VERSION_IPV4 0
#define IP_VERSION_IPV6 0

//色带, range: 1 - 15.
#define MIN_COLOR_BAR 1
#define MAX_COLOR_BAR 15
enum vot_net_videoFrameType
{
	VOT_VIDEO_FRAME_UNKNOWN = 0,
	VOT_VIDEO_FRAME_YUV420P,
	VOT_VIDEO_FRAME_NV12,
	VOT_VIDEO_FRAME_RGB24,
	VOT_VIDEO_FRAME_BGR24,
	VOT_VIDEO_FRAME_GRAY8,
};
typedef void* vot_net_videoFrame;
struct vot_net_frame_data_t {
	vot_net_videoFrameType type;
	char* data;
	int width;
	int height;
	int size;
};


struct vot_net_frame_data_t;
enum vot_net_videoFrameType;
typedef void* HVOTFrame;

enum vot_net_network_card_type_e
{
	NETWORK_CARD_WIRED=0,
	NETWORK_CARD_WIRELESS
};


//网络配置
struct vot_net_network_config
{
	vot_net_network_card_type_e card = NETWORK_CARD_WIRED; //网卡类型：0 有限网卡
	char dns1[MAC_ADDRESS_LENGTH];               // DNS1 地址
	char dns2[MAC_ADDRESS_LENGTH];               // DNS2 地址
	char gateway[MAC_ADDRESS_LENGTH];            // 默认网关
	char host_name[MAX_NAME_LEN];          // 主机名
	int ip_version;              // IP版本 (IPv4 or IPv6)
	char ipaddr[MAC_ADDRESS_LENGTH];             // IPv4 地址
	char mac[MAC_ADDRESS_LENGTH]; // MAC 地址
	int mode;                    // 网络模式
	char netmask[MAC_ADDRESS_LENGTH];            // 子网掩码
	int net6_mode;               // IPv6 模式
	int net6_netmask;            // IPv6 子网掩码
	char net6_gateway[IPV6_ADDRESS_LENGTH]; // IPv6 默认网关
	char net6_ipaddr[IPV6_ADDRESS_LENGTH];  // IPv6 地址
	int net6_flag;               // IPv6 标志
};

//SDK通讯配置
struct vot_net_config {
	char irVideoPath[MAX_URL_LEN];
	int  irVideoPort;
	char irUserName[MAX_USERNAME_LEN];
	char irPassword[MAX_PASSWORD_LEN];

	char ccdVideoPath[MAX_URL_LEN];
	int  ccdVideoPort;
	char ccdUserName[MAX_USERNAME_LEN];
	char ccdPassword[MAX_PASSWORD_LEN];

	int  controlPort;
	char controlUsername[MAX_PASSWORD_LEN];
	char controlPassword[MAX_PASSWORD_LEN];
};

struct vot_net_rtspConfig {
	char ir_rtsp_url[MAX_URL_LEN];
	char ir_sub_rtsp_url[MAX_URL_LEN];
	char vl_rtsp_url[MAX_URL_LEN];
	char vl_sub_rtsp_url[MAX_URL_LEN];
};

enum vot_net_device_status_e
{
	DEVICE_CONNECTED = 1,
	DEVICE_DISCONNECTED = -1,
};
enum vot_net_shape_type_e
{
	SHAPE_POINT = 1,
	SHAPE_LINE = 2,
	SHAPE_RECT = 3,
	SHAPE_POLYGON = 4,
	SHAPE_ELLIPSE = 5,
};
enum vot_net_lable_location_e
{
	LOCATION_ABOVE = 1,
	LOCATION_BELOW = 2,
	LOCATION_LEFT = 3,
	LOCATION_RIGHT = 4,
	LOCATION_CENTER = 5,
};
enum vot_net_show_temp_type_e
{
	SHOWTYPE_GLOBAL_MAX_TEMP = 1,
	SHOWTYPE_GLOBAL_MIN_TEMP = 2,
	SHOWTYPE_MAX_TEMP = 3,
	SHOWTYPE_MIN_TEMP = 4,
	SHOWTYPE_HIDDEN = 5,
	SHOWTYPE_NAME_AND_MAX_TEMP = 6,
	SHOWTYPE_NAME_AND_MIN_TEMP = 7,
	SHOWTYPE_NAME_AND_AVG_TEMP = 7,
};
enum  vot_net_alarm_type_e
{
	ALARMTYPE_HIGH = 1,
	ALARMTYPE_LOW = 2,
	ALARMTYPE_AVG = 3,
	ALARMTYPE_HIGH_LOW,
};
enum vot_net_switch_flag_e {
	FLAG_OFF = 0,
	FLAG_ON = 1,
};
enum vot_net_alarm_condition_e {
	COND_HIGER = 1,
	COND_LOWER = 2
};

struct vot_net_data_t
{
	const char* net_recv_data = nullptr; //控制命令数据
	int net_recv_data_lenght = 0; //控制命令数据长度
};


struct vot_net_point
{
	int x;
	int y;
};
struct vot_net_rule {
	vot_net_alarm_condition_e alarm_condition; //报警条件，1 高于2 低于
	vot_net_switch_flag_e alarm_flag; //是否开启报警1 开启0 不开启
	int alarm_interal;//报警时间间隔，默认为300(5min)，范围0～3600
	int alarm_shake;//报警抖动，单位s ，1～10，默认3s
	vot_net_alarm_type_e alarm_type;//报警类型，1 高温报警 2 低温报警 3 平均温报警 4 高低温报警
	float ambient;//环温
	float atmo_trans = 1.0f;
	float avg_temp;//平均温, -40～2000
	float diff_temp;//温度温差,0～2000
	float dist;//距离，单位米，0.1～200.0
	float emiss;//发射率 0.1～1.0
	int emiss_mode = 2;
	float high_temp;//报警高温阈值，-40～2000，
	int humi;//湿度 ,范围1～100
	int id;
	float low_temp;//报警低温阈值,-40～2000，
	float opti_trans;
	int preset = 0;//预置位，与实际设备支持为准，为对象属性范围[1,256]。针对云台设备：rule_list 中返回所有有效预置位对应的测温规则，不同预置位的不同测温规则，用户可以根据此字段区分；针对非云台设备：preset统一使用0，返回当前测温规则即可。
	int rate_temp;//温度斜率,-600～600
	float ref_temp;//反射温度-40～2000,单位摄氏度
	char rule_name[MAX_NAME_LEN]; //规则名称，字符个数范围：0～20
	vot_net_lable_location_e show_location;//名称显示位置： 1 上方 2 下方 3 左方 4 右方 5 中间
	vot_net_show_temp_type_e show_type; //1全局最高温 2全局最低温 3最高温 4最低温 5不显示 6名称 + 最高温 7名称 + 最低温 8名称 + 平均温
	vot_net_shape_type_e type;//对象类型：1 点2 线3 矩形 4 多边形   5 圆形
	int point_cnt = 0;
	vot_net_point points[32];
};
struct vot_net_rule_list {
	int cnt;
	vot_net_rule list[];
};


struct vot_net_rule_report
{
	int rule_id;
	int type;
	char rule_name[MAX_NAME_LEN];
	float max_temp;
	float min_temp;
	float avg_temp;
	int preset;
};

struct vot_net_report {
	float global_max_temp;
	float global_min_temp;
	float global_avg_temp;
	float max_temp;
	float min_temp;
	int rule_list_cnt;
	vot_net_rule_report rule_list[];
};


// 时间段结构体
struct vot_net_period {
	char start[9 + 1]; // 格式: "HH:MM:SS"，8字符 + 结尾'\0'
	char end[9 + 1];
};

// 每天的设置
struct vot_net_effectDay {
	int day;                      // 1~7
	vot_net_period period[MAX_PERIODS_PER_DAY]; // 当前假设每一天最多一个时间段，也可以改为灵活数组
	int period_count;            // 实际的时间段数量
};

enum vot_net_capture_stream_type_e
{
	CAPTURE_NONE = 0,
	CAPTURE_CCD = 1,
	CAPTURE_IR = 2,
	CAPTURE_CCD_IR = 3
};
enum vot_net_record_stream_type_e
{
	RECORD_NONE = 0,
	RECORD_CCD = 1,
	RECORD_IR = 2,
	RECORD_CCD_IR = 3

};

// 主配置结构体
struct vot_net_alarmConfig {
	vot_net_switch_flag_e  alarm_flag; //是否开启报警 1 开启 0 不开启
	int light_hold; //闪光灯持续时长，间隔闪烁，10～300
	vot_net_switch_flag_e light_flag; //闪光灯是否开启 0 不开启 1 开启
	int alarm_shake;//报警抖动,单位s，1～10，默认3s
	vot_net_switch_flag_e audio_flag;//是否音频联动，默认启用0:否   1 是
	int audio_index;//音乐文件索引，从通用接口可获取0-2
	int audio_mode;// 音频模式，默认次数0：持续时间1：播放次数
	int audio_value; //音乐值，默认10，不区分模式，若区分可以添加字段随模式定义持续时间： 秒数播放次数： 播放次数0～200
	vot_net_switch_flag_e capture_flag;//是否截图， 0：否1：是
	vot_net_capture_stream_type_e capture_stream;//截图类型1 只截图可见光 2 只截图红外 3 截图红外和可见光
	vot_net_effectDay effect_day[DAYS_IN_WEEK];  // 一周 7 天
	int effect_day_count;
	vot_net_switch_flag_e output_flag;//是否外部输出 0 不输出 1 输出
	int output_hold; //是否外部输出0 不输出1 输出
	int record_delay;
	vot_net_switch_flag_e record_flag;//是否录制1 录制0 不录制
	vot_net_record_stream_type_e record_stream; //录制类型 0 不录制 1 只录制可见光 2 只录制红外 3 录制红外和可见光
	int sendmail; //是否发送邮件 0 不发送 1 发送
};



struct vot_net_IrCcdParam {
	int flag;// 开关 0 关闭 1开启 温度显示开关
	int show_mode; //温度显示模式,1 最高温2 最低温3 平均温4 最高温 + 最低温5 最高温 + 平均温6 平均温 + 最低温7 最高温 + 最低问 + 平均温
	int show_mouse = 0;//文档中找不到定义；
	int color_bar; //色带 从1开始
	int color_show;//估计是是否显示颜色
	float dist; //距离，单位米，0.1～200.0
	int humi; //湿度, 范围1～100
	float emiss;//发射率 0.1～1.0
	int gear; //测温挡位索引，目前支持挡位数见500接口，取值与支持挡位同步，值为档位索引。
	float opti_trans = 1.f;
	float mod_temp; //温度修正，范围 - 1～1
	int isot_flag = 0;//文档没有说明
	float ambient;//环温
	int isot_type = 20;//文档找不到定义
	float ref_temp;//反射温度
	int isot_high = 20;//文档找不到定义
	int isot_high_color = 16711680;//文档找不到定义
	int isot_low = 20;//文档找不到定义
	int isot_low_color = 65280;//文档找不到定义
	int show_ir_tm;// 红外 时间：0不显示 1显示;
	int show_vl_tm;//可见光 时间：0不显示 1显示
	int show_ir_desc;//红外通道字符串开关 0不显示 1显示
	int show_vl_desc; //可见光通道字符串开关 0不显示 1显示
	char  ir_desc[64];//红外通道字符串内容
	char vl_desc[64];//红外通道字符串内容
	int show_ir_preset_name;//红外预置点名称字符串 ：1 显示， 0 不显示
	int show_vl_preset_name;//可见光预置点名称字符串 ：1 显示， 0 不显示
	int ir_font_size;//红外字体大小
	int vl_font_size;//可见光字体大小
	int show_ir_position;//红外方位
	int show_vl_position;//可见光方位
	int ir_tm_type; //红外 时间类型
	int vl_tm_type;//红外 时间类型
};


struct vot_net_alarmRule {
	int type;
	int condition;
	int high_temp;
	int low_temp;
	int avg_temp;
	int max_temp;
	int min_temp;
	int objtype;
	struct vot_net_point points[MAX_POINTS];
	int point_count; // 实际点的数量
};

struct vot_net_alarmNotify {
	float high_temp;
	float low_temp;
	float avg_temp;
	int temp_flag;

	char vl_image_url[MAX_URL_LEN];
	char ir_image_url[MAX_URL_LEN];
	char vl_image_content[MAX_URL_LEN];
	char ir_image_content[MAX_URL_LEN];

	int preset;
	char preset_name[MAX_NAME_LEN];

	int type;
	char name[MAX_NAME_LEN];
	char time[MAX_TIME_LEN];

	char vl_video_url[MAX_URL_LEN];
	char ir_video_url[MAX_URL_LEN];

	struct vot_net_alarmRule config;
};

struct vot_net_irData {
	char vl_image_url[MAX_URL_LEN];
	char ir_image_url[MAX_URL_LEN];
	char time[MAX_TIME_LEN];
	char vl_video_url[MAX_URL_LEN];
	char ir_video_url[MAX_URL_LEN];
	int dataSize;
	char data[];
};

//快门配置
struct vot_net_autoShutterConfig
{
	vot_net_switch_flag_e isOn;
	int compensationTime; //n seconds
};
#endif