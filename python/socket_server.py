import asyncio
import websockets
import json

rooms = {}  # room_name -> set(websocket)

async def handler(ws):
    current_rooms = set()
    print("Client connected")

    try:
        async for msg in ws:
            data = json.loads(msg)

            if data["type"] == "joinroom":
                room = data["data"]
                rooms.setdefault(room, set()).add(ws)
                current_rooms.add(room)
                print(f"Joined room: {room}")

            elif data["type"] == "image":
                room = data["room"]
                # broadcast ไปเฉพาะ room
                for client in rooms.get(room, []):
                    if client != ws:
                        await client.send(json.dumps(data))

    except websockets.exceptions.ConnectionClosed:
        print("Client disconnected")

    finally:
        # cleanup
        for room in current_rooms:
            rooms[room].discard(ws)

async def main():
    async with websockets.serve(handler, "0.0.0.0", 8765, max_size=10_000_000):
        print("WebSocket server running ws://0.0.0.0:8765")
        await asyncio.Future()

asyncio.run(main())
