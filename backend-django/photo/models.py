from django.db import models

# Create your models here.

class SinglePhoto(models.Model):
    image = models.ImageField(upload_to='photos/')
    original_file_name = models.CharField(max_length=255, blank=True)
    uploaded_at = models.DateTimeField(auto_now_add=True)

    def save(self, *args, **kwargs):
        # Delete previous image if exists
        if SinglePhoto.objects.exists() and not self.pk:
            SinglePhoto.objects.all().delete()
        super().save(*args, **kwargs)

    def __str__(self):
        return f"Photo uploaded at {self.uploaded_at}"
