import json
from channels.generic.websocket import AsyncWebsocketConsumer # type: ignore

class PhotoConsumer(AsyncWebsocketConsumer):
    async def connect(self):
        await self.channel_layer.group_add('photo_updates', self.channel_name)
        await self.accept()

    async def disconnect(self, close_code):
        await self.channel_layer.group_discard('photo_updates', self.channel_name)

    async def photo_update(self, event):
        await self.send(text_data=json.dumps({
            'type': 'photo_update',
            'image': event['image'],
        })) 