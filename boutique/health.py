from django.http import JsonResponse
from django.views.decorators.http import require_http_methods

@require_http_methods(["GET"])
def health_check(request):
    """Health check endpoint - doesn't require database"""
    return JsonResponse({
        'status': 'ok',
        'message': 'Django app is running!',
        'debug': False
    })
