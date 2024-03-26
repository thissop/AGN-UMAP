import tkinter as tk
from tkinter import messagebox
from PIL import Image, ImageTk
import PIL
import pandas as pd

class ImageFeedbackApp:
    def __init__(self, master, image_path):
        self.master = master
        self.image_path = image_path

        self.master.title("Image Feedback")
        self.master.geometry("1000x500")

        self.image = Image.open(self.image_path)
        self.image = self.image.resize((900, 450), PIL.Image.Resampling.LANCZOS)
        self.img = ImageTk.PhotoImage(self.image)

        self.canvas = tk.Canvas(master, width=self.image.width, height=self.image.height)
        self.canvas.pack()
        self.canvas.create_image(0, 0, anchor=tk.NW, image=self.img)

        self.yes_button = tk.Button(master, text="YES", command=self.on_yes_click)
        self.yes_button.pack(side=tk.LEFT, padx=5, pady=10)

        self.no_button = tk.Button(master, text="NO", command=self.on_no_click)
        self.no_button.pack(side=tk.LEFT, padx=0, pady=10)

        self.maybe_button = tk.Button(master, text="MAYBE", command=self.on_maybe_click)
        self.maybe_button.pack(side=tk.LEFT, padx=5, pady=10)

    def on_yes_click(self):
        self.save_feedback("YES")
        self.master.destroy()

    def on_no_click(self):
        self.save_feedback("NO")
        self.master.destroy()
    
    def on_maybe_click(self):
        self.save_feedback("MAYBE")
        self.master.destroy()

    def save_feedback(self, feedback):
        # Here you can save the feedback to a file or database
        return feedback

def main():
    root = tk.Tk()
    app = ImageFeedbackApp(root, "/Users/yaroslav/Documents/2. work/Research/GitHub/AGN-UMAP/code/monthly/mar2024/wk4/data-selection/images/5618010202-1.png") 
    root.mainloop()

if __name__ == "__main__":
    main()