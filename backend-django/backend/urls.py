from django.contrib import admin
from django.conf import settings
from django.conf.urls.static import static
from django.urls import path, include
from photo.views import serve_media_with_cors

urlpatterns = [
    path('admin/', admin.site.urls),
    path('api/', include('photo.urls')),
    path('media/<path:path>', serve_media_with_cors),
]

