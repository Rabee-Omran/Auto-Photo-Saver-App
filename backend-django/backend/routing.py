from django.urls import re_path
from photo.consumers import PhotoConsumer
 
websocket_urlpatterns = [
    re_path(r'ws/photo/$', PhotoConsumer.as_asgi()),
] 