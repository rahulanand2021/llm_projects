import modal
from pricer_service import app, price
from agents.specialist_agent import SpecialistAgent

def runPricerServiceOnServerLessOnModal():
    with modal.enable_output():
        with app.run():
            result=price.remote("Immersion Blender, Electric Hand Blender 800W with 15 Speed and Turbo Mode Handheld Blender Stainless Steel Blade, 5-in-1")
        print(result)    

def runPricerServiceDeployedAppOnModal():
    pricer = modal.Function.lookup("pricer-service", "price")
    reply = pricer.remote("3-in-1 Food Processor and Chopper, 8 Cup Capacity, 450W Power with Attachments to Shred, Slice, Grind, and Puree, Stainless Steel Blades")
    print(reply)

def runPricerServiceDeployedAppOnModalEnhanced():
    Pricer = modal.Cls.lookup("pricer-service", "Pricer")
    pricer = Pricer()
    reply = pricer.price.remote("Bose Headset QC45")
    print(reply)

def runUsingSpecialAgents():
    agent = SpecialistAgent()
    reply = agent.price("3-Button USB Wired Mouse - Black")
    print(reply)

if __name__ == '__main__':
    # runPricerServiceOnServerLessOnModal()
    # runPricerServiceDeployedAppOnModal()
    # runPricerServiceDeployedAppOnModalEnhanced()
    runUsingSpecialAgents()