import ctypes
import os

# ======================================================
# PATH CONFIG
# ======================================================
SDK_PATH = r"F:\Flutter\Projects\iot_app\python\sdk\bin\x64"
DLL_PATH = os.path.join(SDK_PATH, "votsdk.dll")
os.add_dll_directory(SDK_PATH)
sdk = ctypes.WinDLL(DLL_PATH)

# ======================================================
# BASIC TYPES
# ======================================================
c_int = ctypes.c_int
c_char_p = ctypes.c_char_p
c_void_p = ctypes.c_void_p

# ======================================================
# CALLBACK TYPES
# ======================================================
OnDeviceConnectStatusCB = ctypes.CFUNCTYPE(None, c_void_p, c_int)

# ======================================================
# DEVICE STATUS CALLBACK
# ======================================================
def device_status_cb(tag, status):
    if status == 1:
        print("[Device] Command Connected ✅")
    else:
        print("[Device] Command Disconnected ❌")

device_cb = OnDeviceConnectStatusCB(device_status_cb)

# ======================================================
# FUNCTION MAPPING
# ======================================================
sdk.vot_net_initial.restype = c_int
sdk.vot_net_exit.restype = c_int

sdk.vot_net_createDeviceByIp.argtypes = [c_char_p, ctypes.POINTER(c_int)]
sdk.vot_net_createDeviceByIp.restype = c_int

sdk.vot_net_init.argtypes = [c_int, c_void_p]
sdk.vot_net_init.restype = c_int

sdk.vot_net_openCommandControl.argtypes = [c_int]
sdk.vot_net_openCommandControl.restype = c_int

sdk.vot_net_setCommandStateCallback.argtypes = [c_int, c_void_p, OnDeviceConnectStatusCB]
sdk.vot_net_setCommandStateCallback.restype = c_int

# ======================================================
# 1️⃣ INIT SDK
# ======================================================
ret = sdk.vot_net_initial()
if ret != 1:
    print("[ERROR] SDK init failed")
else:
    print("== SDK initialized ==")

# ======================================================
# 2️⃣ CREATE DEVICE
# ======================================================
dev_id = c_int()
ret = sdk.vot_net_createDeviceByIp(b"192.168.1.168", ctypes.byref(dev_id))
if ret != 1:
    print("[ERROR] Device creation failed")
else:
    print("[DEBUG] Device ID =", dev_id.value)

# ======================================================
# 3️⃣ LOGIN / INIT DEVICE
# ======================================================
class VotNetConfig(ctypes.Structure):
    _fields_ = [
        ("controlPort", c_int),
        ("controlUsername", ctypes.c_char * 64),
        ("controlPassword", ctypes.c_char * 64),
    ]

config = VotNetConfig()
config.controlPort = 9980
config.controlUsername = b"admin"
config.controlPassword = b"admin123"

ret = sdk.vot_net_init(dev_id.value, ctypes.byref(config))
if ret != 1:
    print("[ERROR] Device login failed")
else:
    print("[DEBUG] Device login success")

# ======================================================
# 4️⃣ OPEN COMMAND CONTROL
# ======================================================
ret = sdk.vot_net_openCommandControl(dev_id.value)
if ret != 1:
    print("[ERROR] Open command control failed")
else:
    print("[DEBUG] Command control opened")

# ======================================================
# 5️⃣ SET DEVICE STATUS CALLBACK
# ======================================================
ret = sdk.vot_net_setCommandStateCallback(dev_id.value, None, device_cb)
if ret != 1:
    print("[ERROR] Set device callback failed")
else:
    print("[DEBUG] Device status callback set")

# Keep script running to see callback
input("Press Enter to exit...\n")

sdk.vot_net_exit()
print("SDK exited cleanly ✅")
