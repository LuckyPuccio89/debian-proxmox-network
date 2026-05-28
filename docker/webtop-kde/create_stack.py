import json, urllib.request, urllib.error

TOKEN = "YOUR_PORTAINER_API_TOKEN"

with open("/root/webtop-kde/docker-compose.yml") as f:
    compose = f.read()

payload = json.dumps({
    "Name": "webtop-kde",
    "StackFileContent": compose,
    "ComposeFormat": "compose-2"
}).encode()

req = urllib.request.Request(
    "https://127.0.0.1:9443/api/stacks?endpointId=3&type=1",
    data=payload,
    headers={
        "Authorization": f"Bearer {TOKEN}",
        "Content-Type": "application/json"
    },
    method="POST"
)

try:
    resp = urllib.request.urlopen(req, context=__import__("ssl")._create_unverified_context())
    print(resp.read().decode())
except urllib.error.HTTPError as e:
    print(f"HTTP {e.code}: {e.read().decode()}")
except Exception as e:
    print(f"Error: {e}")
