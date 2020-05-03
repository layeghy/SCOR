# SCOR
**Software-driven Constraint Optimal Routing (SCOR)** is a northbound interface for Software Defined Networking (SDN), which can be used with any SDN controller.
This northbound interface is developed based on the **Constraint Programming** and is implemented in **MiniZinc** constraint modelling language.
SCOR provides an interface for developing **Quality of Service (QoS) routing** applications in SDN such as minimum cost path routing, maximum bandwidth path routing, maximum residual capacity routing, constrained bandwidth minimum delay routing, etc.

SCOR consists of 9 **predicates** (which are similar to functions or methods in procedural programming) as below
  - _Flow path predicate_
  - _Defined Capacity predicate_
  - _Residual Capacity predicate_
  - _apacity Constraint predicate_
  - _Path Cost predicate_
  - _Path Bottleneck predicate_
  - _Link Delay predicate_
  - _Link Utilisation predicate_
  - _Node Capacity predicate_
  
These 9 predicates, which are included in `SCOR Predicates folder`, constitutes the building blocks of the SCOR interface. Each of these predicates models a constraint in networking except the first one,  the flow path predicate, which defines flow/network path.

SCOR models which implement various QoS routing problems are included in `SCOR Models folder`. 
These models are created by combining SCOR predicates and solving for an optimisation or constraint satisfaction.
While currently 21 files are included in this folder, which model 25 different QoS routing problems, there is no
limitation of models that can be created by combining SCOR predicates. The reason why 21 files model 25
QoS routing problem is because some of these files can be used for modelling of more than one 
QoS routing algorithm. For instance, The `bandwidth_constrained_least_cost_path.mzn` file can be used to model
- [x] _Minimum-Cost Bandwidth-Constrained Path_ 
- [x] _Bandwidth-Constrained Least-(static) Delay Path_

routing algorithms. Similarly, the `least_cost_path.mzn`, 
based on the definition of cost, can be used for the modelling of
 - [x] _Least Cost Path_
 - [x] _Shortest Path_
 - [x] _Minimum Loss Path_
 - [x] _Minimum (static) Delay Path_
 
routing problems.     
  
  
