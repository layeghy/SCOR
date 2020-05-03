# SCOR
**Software-driven Constraint Optimal Routing (SCOR)** is a northbound interface for Software Defined Networking (SDN), which can be used with any SDN controller.
This northbound interface is developed based on the **Constraint Programming** and is implemented in **MiniZinc** constraint modelling language.
SCOR provides an interface for developing **Quality of Service (QoS) routing** applications in SDN such as minimum cost path routing, maximum bandwidth path routing, maximum residual capacity routing, constrained bandwidth minimum delay routing, etc.

SCOR consists of 9 **predicates** (which are similar to functions or methods in procedural programming) as below
  - [x] **Flow path predicate**
  - [x] **Defined Capacity predicate**
  - [x] **Residual Capacity predicate**
  - [x] **Capacity Constraint predicate**
  - [x] **Path Cost predicate**
  - [x] **Path Bottleneck predicate**
  - [x] **Link Delay predicate**
  - [x] **Link Utilisation predicate**
  - [x] **Node Capacity predicate**
  
These 9 predicates, which are included in **_SCOR Predicates folder_**, constitutes the building blocks of the SCOR interface. Each of these predicates models a constraint in networking except the first one,  the flow path predicate, which defines flow/network path.

SCOR models which implement various QoS routing problems are included in **_SCOR Models folder_**. 
These models are created by combining SCOR predicates and solving for an optimisation or constraint satisfaction.
While currently 21 files are included in this folder, which model about 30 different QoS routing problems, there is no
limitation of models that can be created by combining SCOR predicates.    
  
  
