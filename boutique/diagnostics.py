import os
import django
from django.http import JsonResponse
from django.views.decorators.http import require_http_methods

@require_http_methods(["GET"])
def diagnostics(request):
    """Show system diagnostics"""
    try:
        django.setup()
        from django.contrib.auth.models import User
        admin_count = User.objects.count()
    except Exception as e:
        admin_count = f"Error: {e}"
    
    db_url = os.environ.get('DATABASE_URL', 'NOT SET')
    if db_url != 'NOT SET':
        # Hide password
        db_url = db_url.replace(f":{os.environ.get('DATABASE_URL', '').split(':')[2].split('@')[0]}@", ":***@")
    
    return JsonResponse({
        'status': 'diagnostics',
        'database_url': db_url,
        'debug': os.environ.get('DEBUG', 'NOT SET'),
        'secret_key': 'SET' if os.environ.get('SECRET_KEY') else 'NOT SET',
        'admin_users_count': admin_count,
        'postgres_host': os.environ.get('POSTGRES_HOST', 'NOT SET'),
        'postgres_db': os.environ.get('POSTGRES_DB', 'NOT SET'),
        'render_service': os.environ.get('RENDER', 'NOT SET'),
        'python_path': os.sys.executable,
    })
