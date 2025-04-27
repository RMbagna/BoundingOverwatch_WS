import tkinter as tk
import numpy as np
from scipy.ndimage import gaussian_filter
import random

# Grid settings
grid_rows = 20
grid_cols = 20
tile_size = 30

# Define color thresholds for traversability
COLORS = {
    'green': '#00FF00',  # High elevation (good traversability)
    'yellow': '#FFFF00', # Moderate elevation
    'red': '#FF0000',    # Low elevation (bad traversability)
}

# Create main window
root = tk.Tk()
root.title("Topographical Traversability and Visibility Map")
canvas = tk.Canvas(root, width=grid_cols * tile_size, height=grid_rows * tile_size)
canvas.pack()

# Generate random noise and smooth it for elevation and darkness
elevation = np.random.rand(grid_rows, grid_cols)
elevation = gaussian_filter(elevation, sigma=2)
elevation = (elevation - np.min(elevation)) / (np.max(elevation) - np.min(elevation))

darkness = np.random.rand(grid_rows, grid_cols)
darkness = gaussian_filter(darkness, sigma=2)
darkness = (darkness - np.min(darkness)) / (np.max(darkness) - np.min(darkness))

# Map elevation to colors
def get_color(value):
    if value > 0.66:
        return COLORS['green']
    elif value > 0.33:
        return COLORS['yellow']
    else:
        return COLORS['red']

# Draw the grid
rectangles = {}
for r in range(grid_rows):
    for c in range(grid_cols):
        x1 = c * tile_size
        y1 = r * tile_size
        x2 = x1 + tile_size
        y2 = y1 + tile_size
        color = get_color(elevation[r, c])
        rect = canvas.create_rectangle(x1, y1, x2, y2, fill=color, outline='black')
        rectangles[rect] = (r, c)

# Tooltip for visibility info
tooltip = tk.Label(root, text="", bg="white", bd=1, relief="solid", font=("Arial", 10))
tooltip.place_forget()

# Event to show visibility on hover
def on_motion(event):
    widget = event.widget
    x, y = event.x, event.y
    col = x // tile_size
    row = y // tile_size
    if 0 <= row < grid_rows and 0 <= col < grid_cols:
        visibility_value = 1.0 - darkness[row, col]  # Brightness = inverse of darkness
        tooltip.config(text=f"Visibility: {visibility_value:.2f}")
        tooltip.place(x=event.x_root - root.winfo_rootx() + 10, y=event.y_root - root.winfo_rooty() + 10)
    else:
        tooltip.place_forget()

# Bind mouse motion to canvas
canvas.bind('<Motion>', on_motion)

root.mainloop()