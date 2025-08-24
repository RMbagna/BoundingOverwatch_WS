# Bounding Overwatch Human-Robot Study

This repository hosts the **Bounding Overwatch Human-Robot Study**, a research platform designed to study human decision-making in human–robot team coordination contexts. The system collects human responses during multi-robot team tasks, and applies **Decision Field Theory (DFT)** to estimate cognitive parameters and project choice evolution.

---

## Project Overview

* **Goal:**
  This study examines how human operators coordinate with robots in high-stakes and low-stakes bounding overwatch scenarios. The goal is to understand how human balance risk involved in critical missions.

* **Key Features:**

  * Human-in-the-loop decision-making experiment design
  * Implementation of **Decision Field Theory (DFT)** for modeling preferencesPerfect — I can integrate your **experiment procedure and context** into the README so it accurately reflects the Bounding Overwatch study while keeping the polished format you liked. Here’s the updated full README draft:

# Bounding Overwatch Human-Robot Study

This repository hosts the **Bounding Overwatch Human-Robot Study**, a research platform designed to study human decision-making in tactical multi-robot team coordination contexts. The system collects human responses during simulated bounding overwatch missions, and applies **Decision Field Theory (DFT)** to estimate cognitive parameters and project choice evolution.

---

## Project Overview

* **Goal:**
  Bounding Overwatch is a critical tactical maneuver used when enemy engagement is highly probable. It involves coordinated teams, where one provides security cover while the other advances. This study investigates how human operators make decisions under high-stakes and low-stakes conditions while relying on robotic assistance. It evaluates how robots influence path selection, risk assessment, and team safety.

* **Key Features:**

  * Human-in-the-loop decision-making experiment design
  * Implementation of **Decision Field Theory (DFT)** for modeling preferences
  * Experimental conditions: High-Stakes vs Low-Stakes missions, Robot Bias, and Robot Neutral
  * A **graphical user interface (GUI)** for participants to interact with multi-robot teams
  * **Data collection** of human decisions and robot selection behavior
  * Integration with **Apollo.R** to estimate DFT-related parameters from human choice data
  * **MATLAB parsing** of estimated parameters to simulate preference dynamics and project decision evolution over time

---

## Experiment Procedure

Your team requires urgent medical assistance in uncharted territory. The robots (blue triangles) are deployed ahead to provide security cover while transmitting critical data on:  
- **Traversability:** Ease of navigation  
- **Visibility:** Limiting exposure to adversaries  
- **Relative positions:** Distance from the operator (red circle)  

Carefully analyze this information and choose your path to ensure the safety of your team while minimizing the risk of detection. Participants are prompted with:  

*"Do you accept the mission?"*

### Scenarios
- **High Stakes:** Rescue Mission during Active Fire  
- **Low Stakes:** Surveying Terrain before Sundown  

### Observed Consequences
- **C1:** High Traversability, Low Exposure to adversary  
- **C2:** Low Traversability, Low Exposure to adversary  
- **C3:** High Traversability, High Exposure to adversary  
- **C4:** Low Traversability, High Exposure to adversary  

### Interaction Guidelines
- Hover the mouse over each robot to see possible consequences.  
- Hover over the operator to see the current traversability and visibility need.  
- If a robot appears behind the legend, refresh the page to reposition elements.

---

## Setup Requirements

* MATLAB (for preference dynamics simulation)
* R Software Program (for Apollo-DFT integration)
* Required R package:
  
  ```
  R
  install.packages("apollo")
  ````

---

## Workflow

1. **Experiment Execution**

   * Participants interact with the GUI and make path decisions based on robot feedback.
   * The study includes two main phases:

     * **Scenario Evaluation:** Participants observe robot-reported terrain data (traversability, visibility, position) and assess risks for each path.
     * **Path Selection & Robot Pairing:** Participants choose a robot-assisted path. Robots differ in attributes (e.g., energy, pace, safety, reliability, computational capacity), and participant choices reveal preference patterns under different stakes.

2. **Parameter Estimation (Apollo.R)**

   * Human response data is processed with Apollo.R to estimate **DFT parameters**.
   * Outputs include individual-level parameter sets (e.g., attention weights, sensitivity, error variance).

3. **Preference Dynamics Simulation (MATLAB)**

   * Estimated parameters are parsed into MATLAB scripts.
   * The system projects **choice evolution** over time, modeling dynamic decision-making under risk and uncertainty using DFT.

---

## Repository Structure

```
├── GUI/                  # Experiment interface for human–robot decision study
├── Data/                 # Collected participant response data (Not included, but recommended)
├── ApolloR/              # Scripts for DFT parameter estimation using Apollo.R
├── Matlab/               # MATLAB scripts for simulating preference dynamics
├── Docs/                 # Supporting documents and references
└── README.md             # Project description and usage guide
```

---

## Getting Started

1. **Clone the Repository**

   ```bash
   git clone https://github.com/RMbagna/BoundingOverwatchStudy.git
   cd BoundingOverwatchStudy
   ```

2. **Run the GUI**

   * Navigate to `GUI/` and launch the experiment interface.

3. **Estimate Parameters with Apollo.R**

   * Follow the scripts in `ApolloR/` to estimate participant-level DFT parameters.

4. **Simulate Preference Dynamics in MATLAB**

   * Use the provided scripts in `Matlab/` to visualize choice evolution.

---

## Research Context

This project is part of ongoing research in **human–robot collaboration** and **cognitive modeling**.
It leverages **Decision Field Theory (DFT)** to provide a process-level understanding of human preferences under uncertainty, task complexity, and tactical risk.

---

## References

* Busemeyer, J. R., & Townsend, J. T. (1993). Decision field theory: A dynamic-cognitive approach to decision making in an uncertain environment. *Psychological Review, 100*(3), 432–459.
* Busemeyer, J. R., Dimperio, E., & Jessup, R. K. (2007). Integrating emotional processes into decision-making models. In W. D. Gray (Ed.), *Integrated Models of Cognitive Systems* (pp. 213–229). Oxford University Press. https://academic.oup.com/book/37037/chapter/322692061
* Hess, S., Palma, D., & Daly, A. (2018). Apollo: A flexible, powerful and customisable freeware package for choice model estimation and application. *Journal of Choice Modelling, 28*, 100170. https://doi.org/10.1016/j.jocm.2018.100170
* Hancock, T. O., Choudhury, C. F., Hess, S., & Stathopoulos, A. (2021). An accumulation of preference: Two alternative dynamic models for understanding transport choices. *Transportation Research Part B: Methodological, 149*, 250–282. https://doi.org/10.1016/j.trb.2021.04.001

---

## Citation

If you use this project in your research, please cite:

```bibtex
@misc{bounding-overwatch,
  author       = {Ryan Mbagna Nanko},
  title        = {Bounding Overwatch Human-Robot Study},
  year         = {2025},
  howpublished = {\url{https://github.com/RMbagna/BoundingOverwatchStudy}}
}

@misc{nanko2025bounding,
  author       = {Ryan Mbagna Nanko},
  title        = {Bounding Overwatch: Investigating Human-Robot Team Coordination through Decision Field Theory},
  year         = {2025},
  howpublished = {\url{<INSERT_LINK_TO_PAPER_OR_REPOSITORY>}},
  note         = {Research study, Clemson University}
}
```

---

## Author

**Ryan Mbagna Nanko**
*Clemson University – I²R Lab (Interdisciplinary & Intelligent Research)*

For questions or collaborations, reach out:
📧 [ryanmbagna@gmail.com](mailto:ryanmbagna@gmail.com) | [rmbagna@clemson.edu](mailto:rmbagna@clemson.edu)
