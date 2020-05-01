%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File:      SCOR Predicate for link utilization
% Objective: Finds the minimum BW (BottleNeck) in the given path of flows
% Github:    https://github.com/layeghy/SCOR
% Author:    Siamak Layeghy, Marius Portmann
% Email:     Siamak.Layeghy@uq.net.au
% Date:      08-11-2017
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

predicate path_bottleneck(
          array[int,int] of var 0..1: Link_Path_Membership,              % array[1..num_edges,1..nFlows] of var 0..1: x
          array[int,int] of int: Link_info,                              % array[1..num_edges,1..4] of 1..99: Link_info)
          array[int] of var int: BottleNeck)=                            % array[1..nFlows] of var int: BottleNeck)
                        
let {
      int: nFlows = max(index_set(BottleNeck)),                          % number of source equals number of flows
      int: num_links = max(index_set_1of2(Link_info)),
      array[int,int] of var 0..1: x = Link_Path_Membership,
      array[1..num_links] of var int: Width;
      array[1..num_links] of var int: W;
}
in
    (
     assert(
            max(index_set_1of2(x)) == num_links                          % memberships must be same as number of links
            /\
            lb_array(x) == 0
            /\
            ub_array(x) == 1,
            "Error: explain this assert error message.",
            forall(j in 1..nFlows)(
                    forall(i in 1..num_links)(Width[i] = Link_info[i,4] * x[i,j])
                    /\
                    forall(i in 1..num_links where Width[i] !=0)( W[i] = Width[i])
                    /\
                    BottleNeck[j] = min(W)
            )
     )
);
