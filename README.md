# SCOR
Software-driven Constraint Optimal Routing (SCOR) is a northbound interface for Software Defined Networking (SDN) which can be used with any SDN controller.
This northbound interface is developed based on the constraint programming techniques and is implemented in MiniZinc constraint modelling language.
SCOR provides and interface for developing Quality of Service (QoS) routing applications in SDN such as minimum cost path routing, maximum bandwidth path routing, maximum residual capacity routing, constrained bandwidth minimum delay routing, etc.
Is is consisted of nine predicates (which are similar to functions or methods in procedural programming) as below
  1. Network path predicate
  2. Defined Capacity predicate
  3. Residual Capacity predicate
  4. Capacity Constraint predicate
  5. Path Cost predicate
  6. Path Bottleneck predicate
  7. Link Delay predicate
  8. Link Utilisation predicate
  9. Node Capacity predicate
  
