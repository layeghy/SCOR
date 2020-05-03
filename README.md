# Software-driven Constraint Optimal Routing (SCOR)
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
  
These 9 predicates, which are included in `SCOR Predicates` folder, constitutes the building blocks of the SCOR interface. Each of these predicates models a constraint in networking except the first one,  the flow path predicate, which defines flow/network path.

SCOR models which implement various QoS routing problems are included in `SCOR Models` folder. 
These models are created by combining SCOR predicates and solving for an optimisation or constraint satisfaction.
While currently 22 files are included in this folder, which model 26 different QoS routing problems, there is no
limitation of models that can be created by combining SCOR predicates. The reason why 22 files model 26
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

The `Sample Model Data` folder includes several example topologies that can be used to try modelled 
QoS routing algorithms. However, there is no guarantee that there is a feasible path for each example data file via 
each QoS routing model. For instance, the `Cube.dzn` topology (example) file is designed to illustrate
the functionality of `wireless_maximum_residual_capacity_path.mzn` model, and its 
functionality has not been checked for other models. The `Grid4.dzn` is tested with a few
models including, `least_cost_path.mzn`, `widest_path.mzn`, `maximum_residual_capacity_path.mzn`, and 
`minmax_link_utilization_path.mzn`. Some of these files such as `Grid4.dzn` are 
written in parametric format to allow easily change the link parameters. In any case, 
these files are only samples to tell the readers how to develop their own example topologies
and use the implemented models.

 SCOR accesses the _network services_ via the SCD controller. As such, SCOR needs a
 controller specific module, **SCOR Specific Controller Module (SCCM)**, that should be implemented for each controller separately.
 However, it is done once, and all the up coming QoS routing algorithms modelled in that 
 controller in SCOR can use the implemented SCCM for that controller. 
The `SCCM [Java]` folder provides the **SCCM** implementation for the **ONOS** SDN controller. 
It consists of 3 files that constitute the source code for an app in ONOS. 
The methodology of developing apps in ONOS can be followed via its website.   
         
  
  
