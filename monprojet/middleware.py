"""
Middleware pour appliquer les migrations automatiquement au démarrage.
"""
from django.core.management import call_command
from django.core.management.base import SystemCheckError
import os
import logging

logger = logging.getLogger(__name__)

# Flag pour éviter d'appliquer les migrations plusieurs fois
_MIGRATIONS_APPLIED = False


class AutoMigrateMiddleware:
    """
    Applique les migrations Django automatiquement au premier accès.
    Utile pour Render et autres PaaS sans accès shell direct.
    """

    def __init__(self, get_response):
        self.get_response = get_response
        self._run_migrations()

    def _run_migrations(self):
        """Applique les migrations une seule fois."""
        global _MIGRATIONS_APPLIED

        if _MIGRATIONS_APPLIED or not os.environ.get('DATABASE_URL'):
            return

        try:
            logger.info("🔄 Applying database migrations...")
            call_command('migrate', verbosity=0, interactive=False)
            logger.info("✅ Migrations applied successfully")
            _MIGRATIONS_APPLIED = True
        except (SystemCheckError, Exception) as e:
            logger.warning(f"⚠️  Migration failed: {e}")
            _MIGRATIONS_APPLIED = True  # Ne pas essayer encore

    def __call__(self, request):
        return self.get_response(request)
