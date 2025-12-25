import ctypes
import os

path = r"F:\Flutter\Projects\iot_app\python\sdk\bin\x64"
os.add_dll_directory(path)

dlls = [
    "avutil-56.dll",
    "avcodec-58.dll",
    "avformat-58.dll",
    "swscale-5.dll",
    "SDL2.dll",
    "libcrypto-3-x64.dll",
    "libssl-3-x64.dll",
    "votplayer.dll",
    "votsdk.dll",
]

for d in dlls:
    try:
        ctypes.WinDLL(path + "\\" + d)
        print(f"{d:25} OK")
    except Exception as e:
        print(f"{d:25} FAILED -> {e}")
