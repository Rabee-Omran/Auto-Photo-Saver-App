from django.shortcuts import render
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.parsers import MultiPartParser, FormParser
from rest_framework import status
from .models import SinglePhoto
from .serializers import SinglePhotoSerializer

from django.http import FileResponse, Http404
from django.conf import settings
import os
from channels.layers import get_channel_layer # type: ignore
from asgiref.sync import async_to_sync

class SinglePhotoView(APIView):
    parser_classes = (MultiPartParser, FormParser)

    def get(self, request, format=None):
        photo = SinglePhoto.objects.first()
        if not photo:
            return Response({'detail': 'No photo found.'}, status=status.HTTP_404_NOT_FOUND)
        serializer = SinglePhotoSerializer(photo, context={'request': request})
        return Response(serializer.data)

    def post(self, request, format=None):
        if 'image' not in request.FILES or not request.FILES['image']:
            return Response({'detail': 'No image file provided.'}, status=status.HTTP_400_BAD_REQUEST)
        
        # Delete existing photos
        SinglePhoto.objects.all().delete()
        
        # Create new photo with image
        image_file = request.FILES['image']
        photo = SinglePhoto.objects.create(
            image=image_file,
            original_file_name=image_file.name
        )
        
        # Serialize and return response
        serializer = SinglePhotoSerializer(photo, context={'request': request})
        
        # Notify WebSocket clients
        channel_layer = get_channel_layer()
        async_to_sync(channel_layer.group_send)(
            'photo_updates',
            {
                'type': 'photo_update',
                'image': serializer.data,
            }
        )
        
        return Response(serializer.data, status=status.HTTP_201_CREATED)


def serve_media_with_cors(request, path):
    file_path = os.path.join(settings.MEDIA_ROOT, path)
    if os.path.exists(file_path):
        response = FileResponse(open(file_path, 'rb'))
        response['Access-Control-Allow-Origin'] = '*'
        return response
    else:
        raise Http404("File not found")