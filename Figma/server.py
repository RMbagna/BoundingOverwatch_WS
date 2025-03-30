from flask import Flask, request, jsonify
import random

app = Flask(__name__)

# Example path planning function (replace with your RRT or other algorithm)
def plan_path(start, goal):
    # Simulate a path for demonstration
    path = []
    current = start
    while current != goal:
        next_step = {
            "row": current["row"] + random.choice([-1, 0, 1]),
            "col": current["col"] + random.choice([-1, 0, 1])
        }
        path.append(next_step)
        current = next_step
    return path

@app.route('/generate-robots', methods=['GET'])
def handle_generate_robots():
    # Generate three random robot positions
    robots = []
    for _ in range(3):
        robot = {
            "row": random.randint(0, 19),  # Assuming a 20x20 grid
            "col": random.randint(0, 19)
        }
        robots.append(robot)
    return jsonify({"robots": robots})

@app.route('/plan-paths', methods=['POST'])
def handle_plan_paths():
    data = request.json
    operator = data['operator']
    robots = data['robots']
    paths = []
    for robot in robots:
        path = plan_path(operator, robot)
        paths.append(path)
    return jsonify({"paths": paths})

if __name__ == '__main__':
    app.run(debug=True)