from django.urls import path
from .views import SinglePhotoView, serve_media_with_cors

urlpatterns = [
    path('photo/', SinglePhotoView.as_view(), name='single-photo'),
    path('media/<path:path>', serve_media_with_cors),
] 