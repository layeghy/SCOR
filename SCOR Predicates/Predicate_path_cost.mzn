%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File:      SCOR Predicate for link utilization
% Objective: Finds the total (additive) costs of given paths of flows
% Github:    https://github.com/layeghy/SCOR
% Author:    Siamak Layeghy, Marius Portmann
% Email:     Siamak.Layeghy@uq.net.au
% Date:      08-11-2017
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

predicate path_cost(
          array[int,int] of var 0..1: Link_Path_Membership,              % array[1..num_edges,1..nFlows] of var 0..1: x
          array[int,int] of int: Link_info,                              % array[1..num_edges,1..4] of 1..99: Link_info)
          array[int] of var int: TotalCost,                              % array[1..nFlows] of int: Total_distance)
          array[int] of int: Flows)=                                     % Number of flows
                        
let {
      int: nFlows = max(index_set(Flows)),
      int: num_links = max(index_set_1of2(Link_info)),
      array[int,int] of var 0..1: x = Link_Path_Membership,
}
in
    (
       assert(
                max(index_set_1of2(x)) == num_links                      % memberships must be same as number of links
                /\
                lb_array(x) == 0
                /\
                ub_array(x) == 1,
                "Error: explain this assert error message.",
                forall(j in 1..nFlows)(
                      TotalCost[j] = sum(i in 1..num_links) (Link_info[i,3] * x[i,j] * Flows[j])
                )
       )
);