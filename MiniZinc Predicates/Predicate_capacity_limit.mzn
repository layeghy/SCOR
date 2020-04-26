
/*
Calcultes the links that their capacities are less than limits according to flows
*/


predicate capacity_limit(
                            array[int,int] of var 0..1: Link_Path_Membership,                 % array[1..num_edges,1..nFlows] of var 0..1: x,
                            array[int] of int: Flow_demands,                                  % array[1..nFlows] of int: Flow_demands,
                            array[int,int] of int: Link_info,                                 % array[1..num_links,1..4] of 1..99: Link_info),
                            array[int] of int: Capacity_limits) =                             % array[1..nFlows] of int: Capacity_limits, requested (required) minimum BW per flow
                        
let {

int: nFlows = max(index_set(Flow_demands)), 

int: num_links = max(index_set_1of2(Link_info)), 

array[int,int] of var 0..1: x = Link_Path_Membership, 

    } 

in 

(
 
assert( 

max(index_set_1of2(x)) == num_links
/\
max(index_set(Capacity_limits)) == nFlows
/\
lb_array(x) == 0
/\
ub_array(x) == 1,

"Either Capacity_limits or Link_Path_Membership arrays dimension is not correct, or Link_Path_Membership range is not [0,1]",

forall(i in 1..num_links)(

forall(j in 1..nFlows)(

if Link_info[i,4] < Limits[j] then membership[i,j] = 0 else true endif

                      )

                         )

      )

);
