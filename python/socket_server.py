import asyncio
import websockets
import json
import asyncpg
from datetime import datetime

rooms = {}  # room_name -> set(websocket)
camera_data = None
camera_owner = None


async def handler(ws):
    global camera_data, camera_owner

    print("Client connected")
    current_rooms = set()

    try:
        async for msg in ws:
            data = json.loads(msg)

            # ==========================
            # JOIN ROOM
            # ==========================
            if data["type"] == "joinroom":
                room = data["data"]
                rooms.setdefault(room, set()).add(ws)
                current_rooms.add(room)
                print(f"Joined room: {room}")

            # ==========================
            # IMAGE BROADCAST
            # ==========================
            elif data["type"] == "image":
                room = data["room"]
                for client in rooms.get(room, []):
                    if client != ws:
                        await client.send(json.dumps(data))

            # ==========================
            # SET CAMERA (Owner only)
            # ==========================
            elif data["type"] == "setCamera":
                camera_data = data["data"]
                camera_owner = ws

                print("Camera set:", camera_data)

            # ==========================
            # GET CAMERA (Others)
            # ==========================
            elif data["type"] == "getCamera":

                if camera_data is None:
                    await ws.send(
                        json.dumps(
                            {
                                "type": "cameraData",
                                "status": "empty",
                                "message": "No camera has been set yet",
                            }
                        )
                    )
                else:
                    await ws.send(
                        json.dumps(
                            {"type": "cameraData", "status": "ok", "data": camera_data}
                        )
                    )

    except websockets.exceptions.ConnectionClosed:
        print("Client disconnected")

    finally:
        # cleanup room
        for room in current_rooms:
            rooms[room].discard(ws)

        # ถ้า owner หลุด → reset camera
        if ws == camera_owner:
            camera_data = None
            camera_owner = None
            print("Camera owner disconnected → cleared camera_data")


async def db_service():
    global db_pool
    db_pool = await asyncpg.create_pool(
        user="postgres",
        password="sunny54164",
        database="smartfarm-src",
        host="49.0.69.152",
    )

    print("DB service started")

    while True:
        try:
            today = datetime.now().weekday()
            now_time = datetime.now().time()
            print("==[Today]==[", today, "][", now_time, "]")

            async with db_pool.acquire() as conn:
                monitors = await conn.fetch(
                    "SELECT monitor_id,is_min,is_max,min_value,max_value,list_time_of_work,datax_value  FROM page_data_manage_monitor ORDER BY monitor_id"
                )
                count = 0
                for row in monitors:
                    times = await conn.fetch(
                        "SELECT * FROM page_data_manage_monitor_sub WHERE monitor_id = $1 ORDER BY start_work",
                        row["monitor_id"],
                    )

                    await check_and_update_monitor(conn, row, times)

                    if count == 4:
                        print("\n")
                        count = 0
                    else:
                        print(end="   \t")
                        count += 1

                print("\n")
                current_time = datetime.now().strftime("%Y-%m-%d")
                # 5️⃣ update สถานะ
                await conn.execute(
                    """
                    UPDATE dashboard_main
                    SET value = $1
                    WHERE name = $2
                    """,
                    current_time,
                    "date_now",
                )
        except Exception as e:
            print(f"[DB ERROR] {e}")
        await asyncio.sleep(10)


async def check_and_update_monitor(conn, row, times):
    monitor_id = row["monitor_id"]

    # ค่าเบื้องต้น
    is_work = 0

    # 1️⃣ เช็ค min / max เปิดอยู่ไหม
    if row["is_min"] == 1 and row["is_max"] == 1:
        min_v = row["min_value"]
        max_v = row["max_value"]
        value = row["datax_value"]

        # 2️⃣ เช็คค่าอยู่ในช่วง
        if min_v <= value <= max_v:

            # 3️⃣ เช็ควัน
            list_days = row["list_time_of_work"]
            if list_days:
                allowed_days = [int(d) for d in list_days.split(",")]
            else:
                allowed_days = []

            today = datetime.now().weekday()

            if today in allowed_days:
                now_time = datetime.now().time()

                # 4️⃣ เช็คช่วงเวลา
                for t in times:
                    start = t["start_work"]
                    end = t["end_work"]

                    if start <= now_time <= end:
                        is_work = 1
                        break

    # 5️⃣ update สถานะ
    await conn.execute(
        """
        UPDATE page_data_manage_monitor
        SET is_work = $1
        WHERE monitor_id = $2
        """,
        is_work,
        monitor_id,
    )

    print(f"[{monitor_id}] → {is_work}", end="")


async def main():
    async with websockets.serve(handler, "0.0.0.0", 8765, max_size=10_000_000):
        print("WebSocket server running ws://0.0.0.0:8765")
        await asyncio.Future()

    # ws_server = websockets.serve(handler, "0.0.0.0", 8765, max_size=10_000_000)
    # print("WebSocket server running ws://0.0.0.0:8765")
    # await asyncio.gather(ws_server, db_service())
    # await asyncio.gather(ws_server)


asyncio.run(main())
