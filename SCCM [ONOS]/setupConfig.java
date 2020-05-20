/*%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
*  File:      AppComponent
*  Objective: This is the third file of three files conforming the SCOR Specific Controller Module (SCCM) for ONOS, this
file include information relating Flow Demands, link Capacities, link Costs, requested QoS Routing algorithm
*  and "Bandwidth-Constrained Least-(static) Delay Path" routing algorithms
*  Github:    https://github.com/layeghy/SCOR
*  Author:    Siamak Layeghy
*  Email:     Siamak.Layeghy@uq.net.au
*  Date:      08-11-2017
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
*                                                                                                                     *
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%*/


package pSCOR.app;

import org.omg.CORBA.Object;
import org.onlab.packet.IpAddress;
import java.util.List;

public class setupConfig {
    public int[] linkCapacities;
    public int[] linkCosts;
    public String routingMethod;
    public String cpSolver;
    public String mznDir;
    public int[] flowLimits;
    public int[] flowDemands;
    public int priority;
    public IpAddress[] srcIps;
    public IpAddress[] dstIps;
    public int[] dstTCPs;
    public short[] ethTypes;
    public Byte[] ip_protos;

    setupConfig() {
        this.linkCapacities = new int[]{1000};
        this.linkCosts = new int[]{1};
        this.routingMethod = "least_cost_path";
        this.cpSolver = "mzn-g12mip";
        this.mznDir = "../SCOR Models (MiniZinc)/";
        this.flowLimits = new int[]{10,10};
        this.flowDemands = new int[]{1,1};
        this.priority = 50000;
        this.srcIps = new IpAddress[]{IpAddress.valueOf("10.0.0.1"), IpAddress.valueOf("10.0.0.1")};
        this.dstIps = new IpAddress[]{IpAddress.valueOf("10.0.0.5"), IpAddress.valueOf("10.0.0.5")};
        this.dstTCPs = new int[] {8000,10000};
        this.ethTypes = new short[]{2048,2048};
        this.ip_protos = new Byte[] {6,6};                    // 6 for TCP and 17 for UDP

    }

}
