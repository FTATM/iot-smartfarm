import cv2
import asyncio
import websockets
import base64
import json
import time
from inference_sdk import InferenceHTTPClient

# ======================
# CONFIG
# ======================
client = InferenceHTTPClient(
    api_key="86OlAwsdbNJi9B662Pct", api_url="http://localhost:9001"
)

WS_URI = "ws://192.168.1.141:8765"

cam_list = {
    "Camera1": "rtsp://192.168.1.168?tcp",
    # "Camera2": "rtsp://192.168.1.168?tcp",
}

FRAME_INTERVAL = 0.3  # ส่งภาพ + infer ~3 FPS (แนะนำสำหรับ AI)
JPEG_QUALITY = 30
RESIZE_W = 640
RESIZE_H = 360

# ======================
# GLOBAL STATE
# ======================
latest_frames = {}  # {cam_name: frame}


# ======================
# CAMERA GRABBER (เร็วมาก)
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
        if ret:
            latest_frames[cam_name] = frame
        else:
            print(f"{cam_name} read failed → reconnecting")
            cap.release()
            await asyncio.sleep(1)
            cap = cv2.VideoCapture(rtsp_url, cv2.CAP_FFMPEG)
            cap.set(cv2.CAP_PROP_BUFFERSIZE, 1)

            # ---------- ENCODE ----------
            ok, buf = cv2.imencode(
                ".jpg", frame, [cv2.IMWRITE_JPEG_QUALITY, JPEG_QUALITY]
            )

            if ok:
                payload = {
                    "type": "image",
                    "room": cam_name,
                    "data": base64.b64encode(buf).decode("utf-8"),
                }
                await ws.send(json.dumps(payload))

        # ห้าม sleep นาน (ต้องอ่าน RTSP ต่อเนื่อง)
        await asyncio.sleep(0)


# ======================
# INFERENCE + SEND WS (ช้าได้)
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
            # resize เพื่อลดภาระ
            frame = cv2.resize(frame, (RESIZE_W, RESIZE_H))

            # ---------- INFERENCE ----------
            try:
                results = await loop.run_in_executor(
                    None, lambda: client.infer(frame, model_id="poultry-thermal-new/1")
                )
            except Exception as e:
                print(f"{cam_name} inference error:", e)
                await asyncio.sleep(0.1)
                continue

            # ---------- DRAW ----------
            annotated = frame.copy()
            h, w = annotated.shape[:2]

            if results and "predictions" in results:
                for pred in results["predictions"]:
                    cx, cy = int(pred["x"]), int(pred["y"])
                    bw, bh = int(pred["width"]), int(pred["height"])

                    x1 = max(0, cx - bw // 2)
                    y1 = max(0, cy - bh // 2)
                    x2 = min(w - 1, cx + bw // 2)
                    y2 = min(h - 1, cy + bh // 2)

                    cv2.rectangle(annotated, (x1, y1), (x2, y2), (0, 255, 0), 2)
                    cv2.putText(
                        annotated,
                        pred["class"],
                        (x1, max(20, y1 - 10)),
                        cv2.FONT_HERSHEY_SIMPLEX,
                        0.7,
                        (0, 255, 0),
                        2,
                    )

            # ---------- ENCODE ----------
            ok, buf = cv2.imencode(
                ".jpg", annotated, [cv2.IMWRITE_JPEG_QUALITY, JPEG_QUALITY]
            )

            if ok:
                payload = {
                    "type": "image",
                    "room": cam_name,
                    "data": base64.b64encode(buf).decode("utf-8"),
                }
                await ws.send(json.dumps(payload))

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
