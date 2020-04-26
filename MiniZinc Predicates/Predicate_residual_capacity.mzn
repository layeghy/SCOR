
/*
Calcultes the residual capacities of all links after locating all flows
*/


predicate residual_capacity(
                            array[int,int] of var 0..1: Link_Path_Membership,                 % array[1..num_edges,1..nFlows] of var 0..1: x,
                            array[int] of int: Flow_demands,                                  % array[1..nFlows] of int: Flow_demands,
                            array[int,int] of int: Link_info,                                 % array[1..num_links,1..4] of 1..99: Link_info)
                            array[int] of var int: Residual_Capacity                          % array[1..num_links] of var int: Residual_Capacity
                                              ) =                                             % int: MAX --> Cmax is the biggest capacity in the network
                        
let {

int: nFlows = max(index_set(Flow_demands)), 

int: num_links = max(index_set_1of2(Link_info)), 

array[int,int] of var 0..1: x = Link_Path_Membership, 

array[int] of var int: Res = Residual_Capacity,

% Finding the maximum capacity of network
int: Cmax = max([Link_info[i,4] | i in 1..num_links]);

    } 

in 

(
 
assert( 

max(index_set_1of2(x)) == num_links
/\
max(index_set(Res)) == num_links
/\
lb_array(x) == 0
/\
ub_array(x) == 1,

"Either Residual_Capacity or Link_Path_Membership arrays dimension is not correct, or Link_Path_Membership range is not [0,1]",

forall(i in 1..num_links)(

%if sum(j in 1..nFlows)(x[i,j])=0 then Res[i] = Cmax

%else Res[i] = Link_info[i,4] - sum(j in 1..nFlows)(Flow_demands[j]*x[i,j]) endif

Res[i] = if sum(j in 1..nFlows)(x[i,j])=0 then Cmax else Link_info[i,4] - sum(j in 1..nFlows)(Flow_demands[j]*x[i,j]) endif
                         )
        )

);