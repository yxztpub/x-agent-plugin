---
name: coding-plan
description: "You MUST use this before any creative work - creating features, building components, adding functionality, or modifying behavior. Explores user intent, requirements and design before implementation."
---
# Code Planning Enforced Workflow (Step 1-4)
## Core Objective
Transform user ideas into implementable design schemas and specification documents, with **mandatory step-by-step execution** to eliminate core step omissions.

---
## Step 1: Mandatory Full Task Clarification (Non-Skippable)
### Operational Requirements
1. Prioritize validating the current project context (existing files, documents, recent commit records).
2. Check for the existence of the task document at `docs/tasks/<task>-task.md`; if present, **must integrate** it as contextual background for task understanding.
3. Refine requirements through **one-on-one Q&A**, with only **1 question per prompt** (multiple choice preferred, open-ended allowed when necessary).
4. Mandatorily clarify three core elements: task purpose, constraints, and success criteria. **Do not proceed to the next step** until all three are fully clarified.
### Acceptance Criteria
The user confirms there is no ambiguity in the task purpose, constraints, and success criteria; a written summary of these elements can be formed.

---
## Step 2: Mandatory Code Implementation Proposal & User Confirmation (Non-Skippable)
### Operational Requirements
1. Based on the clarified task in Step 1, propose **2-3 feasible code/technical implementation solutions**.
2. Each solution must clearly state its **advantages, disadvantages, and applicable scenarios** (trade-off analysis).
3. Prioritize recommending 1 optimal solution with a detailed rationale, aligned with task constraints and success criteria.
4. **mandatorily invoke** the `x-agent-plugin:test-case-generator` skill
5. For backend development, **mandatorily invoke** the `x-agent-plugin:backend-dev` skill and **mandatorily invoke** the `x-agent-plugin:test-driven-development` skill.
6. After presenting the solutions, proactively solicit user feedback and **wait for user confirmation/modification** before proceeding.
### Acceptance Criteria
The user explicitly confirms the selected (or revised) solution is feasible and has no objections.

---
## Step 3: Mandatory Invocation of `x-agent-plugin:writing-plans` Skill (Non-Skippable)
### Operational Requirements
1. Immediately invoke the `x-agent-plugin:writing-plans` skill upon receiving the user's confirmation of the Step 2 solution.
2. Skill invocation must follow the principles of **clarity, conciseness, and structure** to lay the format and content framework for the subsequent design document.
3. Pre-plan the core document modules in advance: Architecture Design, Component Description, Data Flow, Exception Handling, Testing Scheme.
### Acceptance Criteria
The writing skill is successfully invoked; a complete core framework and content draft for the design document are formed with all pre-planned modules included.

---
## Step 4: Mandatory Full Design Document Generation & Saving (Non-Skippable)
### Operational Requirements
1. Based on the framework and draft from Step 3, generate the full design document in small sections (**200-300 words per section**). After completing each section, ask the user *"Is the current content appropriate?"* and proceed only after confirmation.
2. The document **must include all core modules**: Architecture, Components, Data Flow, Error Handling, Testing.
3. Upon completion, save the document to the **mandatory path and format**: `project/docs/plans/YYYY-MM-DD-<topic>-design.md` (replace <topic> with the core task theme).
4. After saving, prompt the user: *"Design document generated. Do you need to commit it to the git repository?"*
5. If implementation is required for follow-up, end with the mandatory question: *"Ready to set up for implementation?"*
### Acceptance Criteria
The design document is saved with the correct path, standard format and complete content; the user confirms the document meets expectations.

---
## Enforced Guiding Principles (Applicable Throughout the Workflow)
1. **YAGNI Principle**: Eliminate all non-essential features; retain only content that meets the core task requirements.
2. **Incremental Validation**: Seek user confirmation at every step and for every section to avoid rework.
3. **Step Enforcemen**: Execute strictly in the order of Step 1→2→3→4; no step skipping or out-of-order execution allowed.
4. **Output Enforcement**: The `project/docs/plans/YYYY-MM-DD-<topic>-design.md` document **must be generated as the final output** with no exceptions.

