% SCOR Predicate

/*
Calcultes the the link utilization percentage after locating all flows
*/


predicate link_utilization(
                            array[int,int] of var 0..1: Link_Path_Membership,                 % array[1..num_edges,1..nFlows] of var 0..1: x,
                            array[int] of int: Flow_demands,                                  % array[1..nFlows] of int: Flow_demands,
                            array[int,int] of int: Link_info,                                 % array[1..num_links,1..4] of 1..99: Edges)
                            array[int] of var float: Utilization) =                           % array[1..num_links] of var float: Utlization
                        
let {

int: MAX = 1000,            % Should be a very big number

int: nFlows = max(index_set(Flow_demands)), 

int: num_links = max(index_set_1of2(Link_info)), 

array[int,int] of var 0..1: x = Link_Path_Membership, 

array[int] of var float: LU = Utilization,

    } 

in 

(
 
assert( 

max(index_set_1of2(x)) == num_links
/\
max(index_set(LU)) == num_links
/\
lb_array(x) == 0
/\
ub_array(x) == 1,

"Either Congestion or Link_Path_Membership arrays dimension is not correct, or Link_Path_Membership range is not [0,1]",

forall(i in 1..num_links)(

LU[i] = (sum(j in 1..nFlows)(Flow_demands[j]*x[i,j]) / Link_info[i,4])*100

                         )

        )

);