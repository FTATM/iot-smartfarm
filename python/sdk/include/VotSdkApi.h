#ifndef VOT_SDK_API_H
#define VOT_SDK_API_H
#include "controlcmd.h"
#include "datadef.h"
#ifdef VOT_SDK
#define  VOT_API __declspec(dllexport)
#else
#define  VOT_API __declspec(dllimport)
#endif
#define VotCall __cdecl
#ifdef __cplusplus
extern "C" {
#endif // __cplusplus
	typedef void (VotCall*OnFrameDataReceivedCB)(void* tag, HVOTFrame frame);
	typedef void (VotCall *OnDeviceConnectStatusCB)(void* tag, vot_net_device_status_e connectStatus);
	typedef void (VotCall *OnNetDataReceivedCB)(void* tag, int isSuccess, const char* data, int len);
	typedef void (VotCall* OnDataStreaamReceivedCB)(void* tag, const char* data, int len);
	typedef void (VotCall *OnNetRuleReportReceivedCB)(void* tag, int isSuccess, vot_net_report* report, const char* errorMsg);
	typedef void (VotCall *OnNetRuleListReceivedCB)(void* tag, int isSuccess, vot_net_rule_list* rule_list, const char* errorMsg);
	typedef void (VotCall *OnNetIrCcdparamReceivedCB)(void* tag, int isSuccess, vot_net_IrCcdParam* param, const char* errorMsg);
	typedef void (VotCall *OnNetAlarmConfigReceivedCB)(void* tag, int isSuccess, vot_net_alarmConfig* alramConfig, const char* errorMsg);
	typedef void (VotCall *OnNetAlarmNotifyCallback)(void* tag, vot_net_alarmNotify* alramConfig);
	typedef void (VotCall* OnNetIrDataCallback)(void* tag, vot_net_irData* irData);
	typedef void (VotCall *OnRtspConfigCallback)(void* tag, int isSuccess, vot_net_rtspConfig* rtspConfig, const char* errorMsg);
	typedef void (VotCall *OnNetworkConfigCallback)(void* tag, int isSuccess, vot_net_network_config* networkConfig, const char* errorMsg);
	typedef void (VotCall* OnShutterConfigCallback)(void* tag, int isSuccess, vot_net_autoShutterConfig* shutterConfig, const char* errorMsg);

	VOT_API vot_net_frame_data_t* VotCall vot_net_GetFrameData(HVOTFrame frame, vot_net_videoFrameType frameType);

	VOT_API void VotCall vot_net_frameData_free(vot_net_frame_data_t* frameData);

	VOT_API const char* VotCall vot_net_getErrorMsg(int retCode);
	VOT_API int VotCall vot_net_initial();
	VOT_API int VotCall vot_net_exit();
	VOT_API int VotCall vot_net_logout(int devId);
	VOT_API int VotCall vot_net_createDeviceByIp(const char* ip, int& m_devId);
	VOT_API int VotCall vot_net_deleteDevice(int devId);
	VOT_API int VotCall vot_net_setIrVideoConnectStateCallback(int devId, void* tag, OnDeviceConnectStatusCB conectStatusCB);
	VOT_API int VotCall vot_net_setCcdVideoConnectStateCallback(int devId, void* tag, OnDeviceConnectStatusCB conectStatusCB);
	VOT_API int VotCall vot_net_setCommandStateCallback(int devId, void* tag, OnDeviceConnectStatusCB conectStatusCB);
	VOT_API int VotCall vot_net_setIrStreamUrl(int devId, const char* url);
	VOT_API int VotCall vot_net_openIrStream(int devID, void* tag, OnFrameDataReceivedCB frameRecvCB);
	VOT_API int VotCall vot_net_closeIrstream(int devID);
	VOT_API int VotCall vot_net_setCcdStreamUrl(int devId, const char* url);
	VOT_API int VotCall vot_net_openCcdStream(int devID, void* tag, OnFrameDataReceivedCB frameRecvCB);
	VOT_API int VotCall vot_net_closeCcdstream(int devID);
	VOT_API int VotCall vot_net_getRtspConfig(int devId, void* tag, OnRtspConfigCallback cb);
	VOT_API int VotCall vot_net_init(int devId, vot_net_config* config);
	VOT_API int VotCall vot_net_openCommandControl(int devId);
	VOT_API int VotCall vot_net_closeCommandControl(int devId);
	VOT_API int VotCall vot_net_sendCommand(int devId, char* cmd, int len, int isQuery);
	VOT_API int VotCall vot_net_ptzControl(int devId, enum PTZ_CmdType cmd, int isStart, int speed, void* tag, OnNetDataReceivedCB cb);
	VOT_API int VotCall vot_net_irControl(int devId, enum Ir_CmdType cmd, int isStart, int speed, void* tag, OnNetDataReceivedCB cb);
	VOT_API int VotCall vot_net_ccDControl(int devId, enum CCD_CmdType cmd, int isStart, int speed, void* tag, OnNetDataReceivedCB cb);
	VOT_API int VotCall vot_net_ptzGoPreset(int devId, int preset, int speed, void* tag, OnNetDataReceivedCB cb);
	VOT_API int VotCall vot_net_ptzSetPreset(int devId, int preset, const char* name, void* tag, OnNetDataReceivedCB cb);
	VOT_API int VotCall vot_net_ptzDeletePreset(int devId, int preset, void* tag, OnNetDataReceivedCB cb);
	VOT_API int VotCall vot_net_getAD(int devId, void* tag, OnNetDataReceivedCB cb);
	VOT_API int VotCall vot_net_getTempTable(int devId, void* tag, OnNetDataReceivedCB cb);
	VOT_API vot_net_rule_list* VotCall vot_net_rule_list_alloc(int count);
	VOT_API void VotCall vot_net_rule_list_free(vot_net_rule_list* ruleList);
	VOT_API int VotCall vot_net_setAnalysisRuleList(int devId, vot_net_rule_list* ruleList, void* tag, OnNetDataReceivedCB cb);
	VOT_API int VotCall vot_net_getAnalysisRuleList(int devId, void* tag, OnNetRuleListReceivedCB cb);
	VOT_API int VotCall vot_net_getAnalysisRuleReport(int devId, void* tag, OnNetRuleReportReceivedCB cb);
	VOT_API int VotCall vot_net_setIrCcdParam(int devId, vot_net_IrCcdParam* param, void* tag, OnNetDataReceivedCB cb);
	VOT_API int VotCall vot_net_setColorBar(int devId, int color_bar, void* tag, OnNetDataReceivedCB cb);
	VOT_API int VotCall vot_net_getIrCcdParam(int devId, void* tag, OnNetIrCcdparamReceivedCB cb);
	VOT_API int VotCall vot_net_setAlarmConfig(int devId, vot_net_alarmConfig* alarmConfig, void* tag, OnNetDataReceivedCB cb);
	VOT_API int VotCall vot_net_getAlarmConfig(int devId, void* tag, OnNetAlarmConfigReceivedCB cb);
	VOT_API int VotCall vot_net_setupAlarmNotifyCallback(int devId, void* tag, OnNetAlarmNotifyCallback cb);
	VOT_API int VotCall vot_net_setupIrDataCallback(int devId, void* tag, OnNetIrDataCallback cb);
	VOT_API int VotCall vot_net_setLogger(int on);
	VOT_API int VotCall vot_net_subscribeAdStream(int devId, void* tag, OnDataStreaamReceivedCB dataCb, OnNetDataReceivedCB cb);
	VOT_API int VotCall vot_net_subscribeTemperatureStream(int devId, void* tag, OnDataStreaamReceivedCB dataCb, OnNetDataReceivedCB cb);
	VOT_API int VotCall vot_net_subscribeTemperatureStreamInRect(int devId, void* tag,int x,int y,int width,int height, OnDataStreaamReceivedCB dataCb, OnNetDataReceivedCB cb);
	VOT_API int VotCall vot_net_unsubscribeAdOrTemperatureStream(int devId, void* tag, OnNetDataReceivedCB cb);

	VOT_API int VotCall vot_net_setNetworkConfig(int devId, vot_net_network_config* networkConfig, void* tag, OnNetDataReceivedCB cb);
	VOT_API int VotCall vot_net_getNetworkConfig(int devId, void* tag, OnNetworkConfigCallback cb);

	VOT_API int VotCall vot_net_setAutoShutterConfig(int devId, vot_net_autoShutterConfig *config, void* tag,OnNetDataReceivedCB cb);
	VOT_API int VotCall vot_net_getAutoShutterConfig(int devId,void* tag, OnShutterConfigCallback cb);

#ifdef __cplusplus
}
#endif

#endif // !VOT_SDK_API_H