from aiohttp import web

async def root(request):
    return web.Response(text=f"BE Response")

app = web.Application()
app.router.add_get('/', root)

if __name__ == '__main__':
    web.run_app(app)

