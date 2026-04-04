"""
URL configuration for monprojet project.
"""
from django.contrib import admin
from django.urls import path, include
from boutique.health import health_check
from boutique.diagnostics import diagnostics

urlpatterns = [
    path('health/', health_check),
    path('diagnostics/', diagnostics),
    path('admin/', admin.site.urls),
    path('', include('boutique.urls')),
]
