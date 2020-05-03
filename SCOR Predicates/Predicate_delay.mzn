/*%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
*  File:      SCOR Predicate for delay
*  Objective: Finds the the Queuing delay in all links after locating all flows
*  Github:    https://github.com/layeghy/SCOR
*  Author:    Siamak Layeghy, Marius Portmann
*  Email:     Siamak.Layeghy@uq.net.au
*  Date:      08-11-2017
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%*/

predicate delay(
          array[int,int] of var 0..1: Link_Path_Membership,              % array[1..num_edges,1..nFlows] of var 0..1: x
          array[int] of int: Flow_demands,                               % array[1..nFlows] of int: Flow_demands
          array[int,int] of int: Link_info,                              % array[1..num_links,1..4] of 1..99: Edges)
          array[int] of var float: Delay) =                              % array[1..num_links] of var float: Delay
                        
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
            max(index_set(Delay)) == num_links
            /\
            lb_array(x) == 0
            /\
            ub_array(x) == 1,
            "Error: explain this assert error message.",
            forall(i in 1..num_links)(
                      sum(j in 1..nFlows)(Flow_demands[j]*x[i,j]) < Link_info[i,4]
            )
            /\
            forall(i in 1..num_links)(
                    if sum(j in 1..nFlows)(Flow_demands[j]*x[i,j]) == 0
                    then Delay[i] = 0
                    else  Delay[i] = 1 / ( Link_info[i,4] - sum(j in 1..nFlows)(Flow_demands[j]*x[i,j]) )
                    endif
            )
   )
);
