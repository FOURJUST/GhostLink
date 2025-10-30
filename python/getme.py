import random
import time
import os

testi = ["Catch me!", "I'm here!", "Where are you clicking?", "Ooooh, come on!", "It's too easy!"]

def speak(message):
    # Afficher un message à la place de la synthèse vocale
    print(message)

def generate_popup_message():
    return random.choice(testi)

def create_popup():
    # Créer un message popup simulé dans la console
    print("=======================================")
    print("Try to catch me!")
    print("=======================================")
    print("Catch!")
    print("=======================================")
    time.sleep(1)
    speak(generate_popup_message())

def main():
    while True:
        create_popup()
        time.sleep(2)  # Pause de 2 secondes avant de créer un nouveau popup

if __name__ == "__main__":
    main()
