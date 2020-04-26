
/*
Limits the all flows in each link to be less than its capacity
In this version CMAX is found autamtically
*/

include "Predicate_residual_capacity.mzn";

predicate capacity_guarantee(
                            array[int,int] of var 0..1: Link_Path_Membership,                 % array[1..num_edges,1..nFlows] of var 0..1: x,
                            array[int] of int: Flow_demands,                                  % array[1..nFlows] of int: Flow_demands,
                            array[int,int] of int: Link_info,                                 % array[1..num_edges,1..4] of 1..99: Link_info)
                            array[int] of var int: Residual_Capacity) =                       % array[1..num_edges] of var int: Residual
                        
let {

int: nFlows = max(index_set(Flow_demands)), 

int: num_links = max(index_set_1of2(Link_info)), 

array[int,int] of var 0..1: x = Link_Path_Membership, 

array[int] of var int: Res = Residual_Capacity;


    } 

in 

(
% constraint for residual capacities
assert(

max(index_set_1of2(x)) == num_links
/\
max(index_set(Res)) == num_links
/\
lb_array(x) == 0
/\
ub_array(x) == 1,

"Either Residual_Capacity or Link_Path_Membership arrays dimension is not correct, or Link_Path_Membership range is not [0,1]",

residual_capacity( x, Flow_demands, Link_info, Res )
/\
forall(i in 1..num_links)(Res[i] >= 0)
     
      )

);