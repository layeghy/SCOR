/*%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
*  File:      AppComponent
*  Objective: This is the first file of three files conforming the SCOR Specific Controller Module (SCCM) for ONOS
*  and "Bandwidth-Constrained Least-(static) Delay Path" routing algorithms
*  Github:    https://github.com/layeghy/SCOR
*  Author:    Siamak Layeghy
*  Email:     Siamak.Layeghy@uq.net.au
*  Date:      08-11-2017
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
*  Note: If running in MiniZinc IDE, the model data can be opened, and fed to the model via Project Explorer.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%*/


package pSCOR.app;


import org.apache.felix.scr.annotations.*;
import org.onlab.packet.*;
import org.onosproject.core.ApplicationId;
import org.onosproject.core.CoreService;
import org.onosproject.net.*;
import org.onosproject.net.flow.FlowRuleService;
import org.onosproject.net.host.HostService;

import org.onosproject.net.topology.TopologyGraph;
import org.onosproject.net.topology.TopologyService;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;




@Component(immediate = true)
public class AppComponent {
    private static final String APP_NAME = "pSCOR.app";
    private final Logger log = LoggerFactory.getLogger(getClass());
    @Reference(cardinality = ReferenceCardinality.MANDATORY_UNARY)       // To register the component
    protected CoreService coreService;
    @Reference(cardinality = ReferenceCardinality.MANDATORY_UNARY)      // To use host services
    protected HostService hostService;
    @Reference(cardinality = ReferenceCardinality.MANDATORY_UNARY)      // To use topology services
    protected TopologyService topologyService;
    @Reference(cardinality = ReferenceCardinality.MANDATORY_UNARY)      // To use flow rule services
    protected FlowRuleService flowRuleService;
    public ApplicationId appId;                                 // The appId will be used in various methods and classes


    // *****************************************Activate the Application ***************************************
    @Activate
    public void activate() {
        appId = coreService.registerApplication(APP_NAME);
        flowScheduler();
        log.info("SCOR Installed its flow rules");
    }


    // *****************************   Flow Scheduler   ******************************
    public void flowScheduler(){
        TopologyGraph graph = topologyService.getGraph(topologyService.currentTopology());
        FrameWork frameWork = new FrameWork(appId,flowRuleService,graph,hostService);
        setupConfig config = new setupConfig();
        int[] linkCapacities = config.linkCapacities;
        int[] linkCosts = config.linkCosts;
        String routingMethod = config.routingMethod;
        String cpSolver = config.cpSolver;
        String mznDir = config.mznDir;
        int[] flowLimits = config.flowLimits;
        int[] flowDemands = config.flowDemands;
        IpAddress[] srcIps = config.srcIps;
        IpAddress[] dstIps = config.dstIps;
        short[] ethTypes = config.ethTypes;
        int[] dstTCPs = config.dstTCPs;
        Byte[] ip_protos = config.ip_protos;
        List<DeviceId> srcDeviceIds = new ArrayList<DeviceId>();
        List<DeviceId> dstDeviceIds = new ArrayList<DeviceId>();
        Host[] srcHosts = new Host[srcIps.length];
        Host[] dstHosts = new Host[srcIps.length];

        for(int i=0;i<srcIps.length;i++){
            Host srcHost = (Host) hostService.getHostsByIp(srcIps[i]).toArray()[0];
            srcHosts[i] = srcHost;
            Host dstHost = (Host) hostService.getHostsByIp(dstIps[i]).toArray()[0];
            dstHosts[i] = dstHost;
            srcDeviceIds.add(srcHost.location().deviceId());
            dstDeviceIds.add(dstHost.location().deviceId());
        }

        List adjacencyList = frameWork.graphTranslator(srcDeviceIds,dstDeviceIds);
        Map routingRules  = frameWork.callMiniZinc(adjacencyList,linkCapacities,linkCosts,routingMethod,
                cpSolver,mznDir,flowLimits,flowDemands);

        if (routingRules.isEmpty()) {
            log.info("There is no route from the source to destination");
        }

        List allForwardRules = (List) routingRules.get("forward");
        List allBackwardRules = (List) routingRules.get("backward");

        // Installing rules relating to all flows
        for(int j=0;j<allForwardRules.size();j++) {
            List forwardRules = (List) allForwardRules.get(j);
            List backwardRules = (List) allBackwardRules.get(j);

            /* Adding the source to backward path and destination to forward path */
            forwardRules.add(dstHosts[j].location());
            backwardRules.add(srcHosts[j].location());

            // Define forward flow to be routed
            List forwardFlow = new   ArrayList();
            forwardFlow.add(srcIps[j]);
            forwardFlow.add(0);
            forwardFlow.add(dstIps[j]);
            forwardFlow.add(dstTCPs[j]);
            forwardFlow.add(ip_protos[j]);

            // Define forward flow to be routed
            List backwardFlow = new ArrayList();
            backwardFlow.add(dstIps[j]);
            backwardFlow.add(dstTCPs[j]);
            backwardFlow.add(srcIps[j]);
            backwardFlow.add(0);
            backwardFlow.add(ip_protos[j]);

            log.info("forwardRules: " + forwardRules.toString());
            log.info("backwardRules: " + backwardRules.toString());

            /* install forward rules */
            frameWork.flowsInstaller(ethTypes[j], forwardRules, forwardFlow);

            /* install backward rules */
            frameWork.flowsInstaller(ethTypes[j], backwardRules, backwardFlow);
            log.info("------------ the flow rules are installed --------------");
        }
    }


    // ********************************   deactivate   *******************************
    @Deactivate
    public void deactivate() {
        log.info("Rules installed by SCOR are removed");
        flowRuleService.removeFlowRulesById(appId);
    }
}