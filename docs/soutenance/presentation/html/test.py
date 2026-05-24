import asyncio
from playwright.async_api import async_playwright

async def main():
    async with async_playwright() as p:
        browser = await p.chromium.launch()
        page = await browser.new_page(viewport={"width": 1600, "height": 900})
        await page.goto("file:///home/claude/presentation/index.html")
        await page.wait_for_timeout(1500)
        # Capture splash
        await page.screenshot(path="/home/claude/presentation/test_01_splash.png")
        print("✓ Splash capturé")

        # Cliquer Commencer pour entrer en présentation
        await page.click('.splash-action')
        await page.wait_for_timeout(2000)
        await page.screenshot(path="/home/claude/presentation/test_02_slide1.png")
        print("✓ Slide 1 en mode présentation capturée")

        # Avancer 3 fois
        for i in range(3):
            await page.keyboard.press("ArrowRight")
            await page.wait_for_timeout(800)
        await page.screenshot(path="/home/claude/presentation/test_03_slide4.png")
        print("✓ Slide 4 après navigation")

        # Ouvrir overview
        await page.keyboard.press("o")
        await page.wait_for_timeout(2000)
        await page.screenshot(path="/home/claude/presentation/test_04_overview.png", full_page=True)
        print("✓ Overview capturé")

        await browser.close()

asyncio.run(main())
