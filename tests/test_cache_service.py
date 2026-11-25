import importlib
import os
import sys
import types
import unittest
from unittest.mock import patch


class CacheServiceTests(unittest.TestCase):
    def test_uses_redis_url_and_configured_ttl(self):
        class FakeRedis:
            @classmethod
            def from_url(cls, url, **kwargs):
                if url != "rediss://user:password@redis.example:6380/2":
                    raise ValueError("incorrect Redis URL")
                return cls()

            def ping(self):
                return True

            def setex(self, key, ttl, value):
                self.saved = (ttl, value)

        modules = {
            "redis": types.SimpleNamespace(Redis=FakeRedis),
            "dotenv": types.SimpleNamespace(load_dotenv=lambda: None),
        }
        with patch.dict(sys.modules, modules), patch.dict(os.environ, {
            "REDIS_URL": "rediss://user:password@redis.example:6380/2",
            "REDIS_TTL": "42",
        }):
            import config
            import services.cache_service as cache_service
            importlib.reload(config)
            importlib.reload(cache_service)
            cache = cache_service.CacheService()
            self.assertIsNotNone(cache.client)
            cache.cache_response("question", {"answer": "yes"})
            self.assertEqual(cache.client.saved, (42, '{"answer": "yes"}'))


if __name__ == "__main__":
    unittest.main()
