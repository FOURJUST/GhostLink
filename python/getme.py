import tkinter as tk
import tkinter.ttk as ttk
import random
import pyttsx3
import subprocess
import sys

try:
    motore = pyttsx3.init()
except ImportError:
    subprocess.check_call([sys.executable, "-m", "pip", "install", "pyttsx3"])
    motore = pyttsx3.init()

testi = ["Catch me!", "I'm here!", "Where are you clicking?", "Ooooh, come on!", "It's too easy!"]

class Popup:
    def __init__(self, master):
        self.master = master
        self.popup = tk.Toplevel(master)
        self.popup.title("Try to catch me!")
        self.popup.protocol("WM_DELETE_WINDOW", self.close_popup)

        message_label = ttk.Label(self.popup, text="Try to catch me!", font=("Helvetica", 18, "bold"), foreground="white", background="black")
        message_label.pack(pady=20)

        self.close_button = ttk.Button(self.popup, text="Catch!", command=self.close_popup)
        self.close_button.pack(pady=10)

        self.popup.style = ttk.Style(self.popup)
        self.popup.style.configure("Popup.TFrame", background="black")
        self.popup.style.configure("TButton", background="white", font=("Helvetica", 14))
        self.popup.style.configure("TLabel", foreground="white", background="black", font=("Helvetica", 14))

        self.popup_frame = ttk.Frame(self.popup, style="Popup.TFrame", width=200)
        self.popup_frame.pack_propagate(0)
        self.popup_frame.pack()

        self.x = random.randint(0, master.winfo_screenwidth() - 200)
        self.y = random.randint(0, master.winfo_screenheight() - 100)
        self.popup.geometry(f"+{self.x}+{self.y}")

    def close_popup(self):
        self.popup.destroy()
        Popup(self.master)
        motore.say(random.choice(testi))
        motore.runAndWait()

root = tk.Tk()
root.withdraw()

popup = Popup(root)
root.mainloop()
