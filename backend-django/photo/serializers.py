from rest_framework import serializers
from .models import SinglePhoto

class SinglePhotoSerializer(serializers.ModelSerializer):
    file_size = serializers.SerializerMethodField()

    class Meta:
        model = SinglePhoto
        fields = ['id', 'image', 'original_file_name', 'file_size', 'uploaded_at']

    def get_image_url(self, obj):
        if obj.image and hasattr(obj.image, 'url') and obj.image.name:
            request = self.context.get('request')
            url = obj.image.url
            if request is not None:
                return request.build_absolute_uri(url)
            return url
        return None

    def get_file_size(self, obj):
        if obj.image and obj.image.name and hasattr(obj.image, 'size'):
            return obj.image.size
        return None 