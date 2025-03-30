import pygame

# Initialize Pygame
pygame.init()

# Screen settings
WIDTH, HEIGHT = 800, 600
screen = pygame.display.set_mode((WIDTH, HEIGHT))
pygame.display.set_caption("Mission: Urgent Medical Assistance in Uncharted Territory")

# Colors
WHITE = (255, 255, 255)
BLUE = (0, 0, 255)
RED = (255, 0, 0)
BLACK = (0, 0, 0)
GREEN = (0, 255, 0)
YELLOW = (255, 255, 0)

# Robot and operator positions
robots = [
    {"id": 1, "x": 200, "y": 400, "visibility": 80, "traversability": 60, "success": "High"},
    {"id": 2, "x": 400, "y": 300, "visibility": 60, "traversability": 80, "success": "Marginal"},
    {"id": 3, "x": 600, "y": 500, "visibility": 70, "traversability": 50, "success": "Low"},
]
operator = {"x": 100, "y": 100}

selected_robot = None
font = pygame.font.Font(None, 28)

# Function to draw text
def draw_text(text, x, y, color=BLACK):
    text_surface = font.render(text, True, color)
    screen.blit(text_surface, (x, y))

# Main loop
running = True
while running:
    screen.fill(WHITE)
    
    # Draw header
    draw_text("Mission: Urgent Medical Assistance in Uncharted Territory", 200, 10, BLACK)
    draw_text("[Home] [Background] [Contact Us] [Safety Score] [Risk Score]", 200, 40, BLACK)
    draw_text("[Quit]", 720, 40, RED)
    
    # Draw operator
    pygame.draw.circle(screen, RED, (operator["x"], operator["y"]), 10)
    draw_text("Operator", operator["x"] - 20, operator["y"] - 20, RED)
    
    # Draw robots
    for robot in robots:
        pygame.draw.polygon(screen, BLUE, [(robot["x"], robot["y"]), (robot["x"] - 10, robot["y"] + 20), (robot["x"] + 10, robot["y"] + 20)])
        draw_text(f"R{robot['id']}", robot["x"] - 10, robot["y"] - 30, BLUE)
    
    # Display robot details if selected
    if selected_robot:
        draw_text(f"Robot {selected_robot['id']}", 20, 80)
        draw_text(f"Visibility: {selected_robot['visibility']}%", 20, 110)
        draw_text(f"Traversability: {selected_robot['traversability']}%", 20, 140)
        color = GREEN if selected_robot['success'] == "High" else YELLOW if selected_robot['success'] == "Marginal" else RED
        draw_text(f"Mission Success: {selected_robot['success']}", 20, 170, color)
    
    # Draw selection instructions
    draw_text("Select Robot Path:", 20, 220)
    draw_text("[ ] Robot 1", 20, 250)
    draw_text("[ ] Robot 2", 20, 280)
    draw_text("[ ] Robot 3", 20, 310)
    draw_text("(Click a robot to select)", 20, 340, BLACK)
    
    # Draw footer buttons
    draw_text("[Next]", 350, 550, BLACK)
    draw_text("[Switch]", 450, 550, BLACK)
    
    # Event handling
    for event in pygame.event.get():
        if event.type == pygame.QUIT:
            running = False
        elif event.type == pygame.MOUSEBUTTONDOWN:
            mx, my = pygame.mouse.get_pos()
            for robot in robots:
                if robot["x"] - 10 < mx < robot["x"] + 10 and robot["y"] - 20 < my < robot["y"]:
                    selected_robot = robot
    
    pygame.display.flip()

pygame.quit()
