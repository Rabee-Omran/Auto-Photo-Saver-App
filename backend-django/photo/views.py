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
        serializer = SinglePhotoSerializer(data=request.data, context={'request': request})
        if serializer.is_valid():
            SinglePhoto.objects.all().delete()
            instance = serializer.save()
            instance.original_file_name = request.FILES['image'].name
            instance.save()
            response_serializer = SinglePhotoSerializer(instance, context={'request': request})
            return Response(response_serializer.data, status=status.HTTP_201_CREATED)
        print(serializer.errors)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


def serve_media_with_cors(request, path):
    file_path = os.path.join(settings.MEDIA_ROOT, path)
    if os.path.exists(file_path):
        response = FileResponse(open(file_path, 'rb'))
        response['Access-Control-Allow-Origin'] = '*'
        return response
    else:
        raise Http404("File not found")