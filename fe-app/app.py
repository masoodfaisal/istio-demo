import requests
from aiohttp import web

async def root(request):
    be_response = requests.get("http://be-app.istio-demo.svc.cluster.local:8080/")
    return web.Response(text=f"Respomse from BE App {be_response.text}")

app = web.Application()
app.router.add_get('/', root)

if __name__ == '__main__':
    web.run_app(app)

