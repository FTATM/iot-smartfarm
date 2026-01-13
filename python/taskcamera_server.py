import cv2
import asyncio
import websockets
import base64
import json
import time
import numpy as np
from inference_sdk import InferenceHTTPClient

# ======================
# CONFIG
# ======================
client = InferenceHTTPClient(
    api_key="86OlAwsdbNJi9B662Pct", api_url="http://localhost:9001"
)

WS_URI = "ws://localhost:8765"

cam_list = {
    "Camera1": "rtsp://192.168.1.168:554/",  #เปลี่ยน IP เป็น IP camera ของคุณ ที่นี่
}

FRAME_INTERVAL = 0.3  # ~3 FPS
JPEG_QUALITY = 30
RESIZE_W = 640
RESIZE_H = 360

# IR → °C
# SCALE = 0.06
# OFFSET = 25

SCALE = 0.16
OFFSET = 0

latest_frames = {}  # {cam_name: frame}


# ======================
# CAMERA GRABBER + THERMAL MAP
# ======================
async def grabber(ws, cam_name, rtsp_url):
    cap = cv2.VideoCapture(rtsp_url, cv2.CAP_FFMPEG)
    cap.set(cv2.CAP_PROP_BUFFERSIZE, 1)

    if not cap.isOpened():
        print(f"{cam_name} cannot open stream")
        return

    print(f"{cam_name} grabber started")

    while True:
        ret, frame = cap.read()
        if not ret:
            print(f"{cam_name} read failed → reconnecting")
            cap.release()
            await asyncio.sleep(1)
            cap = cv2.VideoCapture(rtsp_url, cv2.CAP_FFMPEG)
            cap.set(cv2.CAP_PROP_BUFFERSIZE, 1)
            continue

        # ---------- IR → Thermal ----------
        frame = cv2.resize(frame, (RESIZE_W, RESIZE_H))

        # gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY) if len(frame.shape) == 3 else frame
        # temp = gray.astype(np.float32) * SCALE + OFFSET
        # temp_norm = cv2.normalize(temp, None, 0, 255, cv2.NORM_MINMAX).astype(np.uint8)
        # thermal_map = cv2.applyColorMap(temp_norm, cv2.COLORMAP_JET)

        latest_frames[cam_name] = frame  # เก็บ frame ล่าสุด

        # # ---------- SEND WS ----------
        # ok, buf = cv2.imencode(".jpg", thermal_map, [cv2.IMWRITE_JPEG_QUALITY, JPEG_QUALITY])
        # if ok:
        #     payload = {
        #         "type": "image",
        #         "room": cam_name,
        #         "data": base64.b64encode(buf).decode("utf-8"),
        #     }
        #     try:
        #         await ws.send(json.dumps(payload))
        #     except:
        #         pass

        await asyncio.sleep(0)


# ======================
# OPTIONAL: INFERENCE
# ======================
async def infer_and_send(ws, cam_name):
    loop = asyncio.get_running_loop()
    last_send = 0
    print(f"{cam_name} infer task started")

    while True:
        frame = latest_frames.get(cam_name)
        if frame is None:
            await asyncio.sleep(0.05)
            continue

        now = time.time()
        if now - last_send >= FRAME_INTERVAL:

            # สร้าง thermal map ของ crop
            temp_norm = cv2.normalize(frame, None, 0, 255, cv2.NORM_MINMAX).astype(
                np.uint8
            )
            thermal_frame = cv2.applyColorMap(temp_norm, cv2.COLORMAP_JET)
            # ---------- INFERENCE ----------
            try:
                results = await loop.run_in_executor(
                    None,
                    lambda: client.infer(
                        thermal_frame, model_id="poultry-thermal-new/1"
                    ),
                )
            except Exception as e:
                print(f"{cam_name} inference error:", e)
                await asyncio.sleep(0.1)
                continue

            crops_data = []  # เก็บข้อมูล temp + crop image

            if results and "predictions" in results:
                for pred in results["predictions"]:
                    cx, cy = int(pred["x"]), int(pred["y"])
                    bw, bh = int(pred["width"]), int(pred["height"])
                    x1 = max(0, cx - bw // 2)
                    y1 = max(0, cy - bh // 2)
                    x2 = min(RESIZE_W - 1, cx + bw // 2)
                    y2 = min(RESIZE_H - 1, cy + bh // 2)
                    crop = frame[y1:y2, x1:x2]
                    gray = (
                        cv2.cvtColor(crop, cv2.COLOR_BGR2GRAY)
                        if len(crop.shape) == 3
                        else crop
                    )
                    temp = gray.astype(np.float32) * SCALE + OFFSET

                    max_temp = np.max(temp)
                    min_temp = np.min(temp)
                    avg_temp = np.mean(temp)

                    cv2.rectangle(thermal_frame, (x1, y1), (x2, y2), (255, 255, 255), 2)
                    cv2.putText(
                        thermal_frame,
                        pred["class"] + f" {round(float(max_temp),2)}°C",
                        (x1, max(20, y1 - 10)),
                        cv2.FONT_HERSHEY_SIMPLEX,
                        0.7,
                        (255, 255, 255),
                        2,
                    )

                    crops_data.append(
                        {
                            "bbox": [x1, y1, x2, y2],
                            "class": pred["class"],
                            "max_temp": float(max_temp),
                            "min_temp": float(min_temp),
                            "avg_temp": float(avg_temp),
                        }
                    )
            ok, buf = cv2.imencode(
                ".jpg", thermal_frame, [cv2.IMWRITE_JPEG_QUALITY, JPEG_QUALITY]
            )
            # ส่ง WS ทั้งหมด
            if ok:
                payload = {
                    "type": "image",
                    "room": cam_name,
                    "data": base64.b64encode(buf).decode("utf-8"),
                    "crops": crops_data,
                }
                try:
                    await ws.send(json.dumps(payload))
                except:
                    pass

            last_send = now

        await asyncio.sleep(0.01)


# ======================
# MAIN
# ======================
async def main():
    async with websockets.connect(
        WS_URI, max_size=10_000_000, ping_interval=20, ping_timeout=20
    ) as ws:
        # join ทุก room
        for cam in cam_list:
            await ws.send(json.dumps({"type": "joinroom", "data": cam}))
            print(f"Joined room {cam}")

        tasks = []
        for cam_name, rtsp_url in cam_list.items():
            tasks.append(asyncio.create_task(grabber(ws, cam_name, rtsp_url)))
            tasks.append(asyncio.create_task(infer_and_send(ws, cam_name)))

        await asyncio.gather(*tasks)


# ======================
# RUN
# ======================
asyncio.run(main())
