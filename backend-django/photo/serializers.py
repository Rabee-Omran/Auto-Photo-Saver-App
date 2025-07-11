from rest_framework import serializers
from .models import SinglePhoto
import os

class SinglePhotoSerializer(serializers.ModelSerializer):
    image = serializers.SerializerMethodField()
    file_size = serializers.SerializerMethodField()

    class Meta:
        model = SinglePhoto
        fields = ['id', 'image', 'original_file_name', 'file_size', 'uploaded_at']

    def get_image(self, obj):
        if obj.image and hasattr(obj.image, 'name') and obj.image.name:
            return os.path.basename(obj.image.name)
        return None

    def get_file_size(self, obj):
        if obj.image and obj.image.name and hasattr(obj.image, 'size'):
            return obj.image.size
        return None

    def create(self, validated_data):
        # Handle image upload properly
        image = self.context['request'].FILES.get('image')
        if image:
            validated_data['image'] = image
        return super().create(validated_data) 