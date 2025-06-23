import modal
from llama import app, generate
from pricer_service import appPricer, price

def runOllamaServerLessOnModal():
    with modal.enable_output():
        with app.run():
            result=generate.remote("Life is a mystery, everyone must stand alone, I hear")
        print(result)

def runPricerServiceOnServerLessOnModal():
    with modal.enable_output():
        with appPricer.run():
            result=price.remote("Immersion Blender, Electric Hand Blender 800W with 15 Speed and Turbo Mode Handheld Blender Stainless Steel Blade, 5-in-1")
        print(result)    

if __name__ == '__main__':
    # runOllamaServerLessOnModal()
    runPricerServiceOnServerLessOnModal()