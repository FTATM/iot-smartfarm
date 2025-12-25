import cv2
import numpy as np
import time

# =========================
# CONFIGURATION
# =========================
RTSP_URL = "rtsp://192.168.1.168:554/"  # ลิ้งค์กล้อง IR
SCALE = 0.04    # AD → °C scale (ปรับตามกล้อง)
OFFSET = 25  # AD → °C offset (ปรับตามกล้อง)

# =========================
# OPEN RTSP STREAM
# =========================
print("🔹 Opening RTSP stream...")
cap = cv2.VideoCapture(RTSP_URL)
if not cap.isOpened():
    print("❌ Cannot open RTSP stream")
    exit(1)

print("✅ RTSP stream opened successfully")

# =========================
# MAIN LOOP
# =========================
while True:
    ret, frame = cap.read()
    if not ret:
        print("[WARN] Frame not received")
        time.sleep(0.1)
        continue

    # สมมติว่ากล้อง IR เป็น grayscale single channel
    if len(frame.shape) == 3:
        gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
    else:
        gray = frame

    # แปลง pixel → temperature
    temp = gray.astype(np.float32) * SCALE + OFFSET

    # สร้าง thermal map
    temp_norm = cv2.normalize(temp, None, 0, 255, cv2.NORM_MINMAX).astype(np.uint8)
    thermal_map = cv2.applyColorMap(temp_norm, cv2.COLORMAP_JET)

    # Overlay Max / Min / Avg
    max_temp = np.max(temp)
    min_temp = np.min(temp)
    avg_temp = np.mean(temp)
    cv2.putText(thermal_map, f"Max: {max_temp:.1f}C", (10,30),
                cv2.FONT_HERSHEY_SIMPLEX, 1, (255,255,255), 2)
    cv2.putText(thermal_map, f"Min: {min_temp:.1f}C", (10,70),
                cv2.FONT_HERSHEY_SIMPLEX, 1, (255,255,255), 2)
    cv2.putText(thermal_map, f"Avg: {avg_temp:.1f}C", (10,110),
                cv2.FONT_HERSHEY_SIMPLEX, 1, (255,255,255), 2)

    # แสดงภาพ
    cv2.imshow("Thermal Map", thermal_map)

    # Debug log
    print(f"[DEBUG] Frame received - Max: {max_temp:.1f}C, Min: {min_temp:.1f}C, Avg: {avg_temp:.1f}C")

    key = cv2.waitKey(1) & 0xFF
    if key == ord('q') or key == ord('Q'):
        print("❌ Quit pressed")
        break

# =========================
# CLEANUP
# =========================
cap.release()
cv2.destroyAllWindows()
print("✅ Stream closed")
