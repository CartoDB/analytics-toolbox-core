import json
import os
import time
import urllib.parse
import urllib.request


TOKEN_PATH = '/oidc/v1/token'
REFRESH_MARGIN_SECONDS = 300

_token = None
_expires_at = 0.0


def get_access_token():
    """Return a Databricks access token, renewing it before it expires.

    DB_TOKEN wins when set, so local runs and personal access tokens keep
    working unchanged. Otherwise a token is requested with the service
    principal credentials and reused until it is close to expiring.
    """
    token = os.getenv('DB_TOKEN')
    if token:
        return token

    global _token, _expires_at
    if _token is None or time.monotonic() >= _expires_at:
        _token, expires_in = _request_token()
        _expires_at = time.monotonic() + max(expires_in - REFRESH_MARGIN_SECONDS, 0)
    return _token


def _request_token():
    host = os.environ['DB_HOST_NAME']
    payload = urllib.parse.urlencode(
        {
            'grant_type': 'client_credentials',
            'client_id': os.environ['DB_CLIENT_ID'],
            'client_secret': os.environ['DB_CLIENT_SECRET'],
            'scope': 'all-apis',
        }
    ).encode()
    request = urllib.request.Request(
        f'https://{host}{TOKEN_PATH}',
        data=payload,
        headers={'Content-Type': 'application/x-www-form-urlencoded'},
    )
    with urllib.request.urlopen(request, timeout=30) as response:
        body = json.load(response)
    return body['access_token'], int(body.get('expires_in', 3600))
