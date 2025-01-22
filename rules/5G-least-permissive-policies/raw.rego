package armo_builtins

import future.keywords.in

deny[msga] {
    # workloads := input.spec.workloads
     	workloads := [w |  w= input[_]; w.kind == "WorkloadConfig"]
        work := workloads[_]
        # work_list := work.spec.workloads[_]

        pods := [p | p = input[_]; p.kind == "Deployment"]
        pod := pods[_]
        not labels_match(work, pod)

        msga := {
		"alertMessage": sprintf("Workload %v is not present", [pod.metadata.name]),
		"packagename": "armo_builtins",
		"alertScore": 7,
		"failedPaths": [],
		"fixPaths": [],
		"alertObject": {
			"k8sApiObjects": [pod]
		}
	}
}


deny[msga] {

     	workloads := [w |  w= input[_]; w.kind == "WorkloadConfig"]
        work := workloads[_]

        pods := [p | p = input[_]; p.kind == "Deployment"]
        pod := pods[_]

		kubearmorpolicies := [kubearmorpolicie |  kubearmorpolicie= input[_]; kubearmorpolicie.kind == "KubeArmorPolicy"]
        labels_match(work, pod)
		kubearmor_policies_connected_to_pod := [kubearmorpolicie |  kubearmorpolicie= kubearmorpolicies[_];  check_zerotrust(work, kubearmorpolicie)]
		count(kubearmor_policies_connected_to_pod) < 1


        msga := {
		"alertMessage": sprintf("Workload %v does NOT have any Kubearmor policy", [pod.metadata.name]),
		"packagename": "armo_builtins",
		"alertScore": 7,
		"failedPaths": [],
		"fixPaths": [{"path": sprintf("There are no Kubearmor Policies for 5G workloads: %v. Please add them", [kubearmor_policies_connected_to_pod]), "value":"false"}],
		"alertObject": {
			"k8sApiObjects": [pod]
		}
	}
}

# deny[msga] {

#      	workloads := [w |  w= input[_]; w.kind == "WorkloadConfig"]
#         work := workloads[_]

#         pods := [p | p = input[_]; p.kind == "Deployment"]
#         pod := pods[_]

# 		kubearmorpolicies := [kubearmorpolicie |  kubearmorpolicie= input[_]; kubearmorpolicie.kind == "KubeArmorPolicy"]
#         labels_match(work, pod)
# 		kubearmor_policies_connected_to_pod := [kubearmorpolicie |  kubearmorpolicie= kubearmorpolicies[_];  check_zerotrust(work, kubearmorpolicie)]
# 		count(kubearmor_policies_connected_to_pod) > 0
		 
#         msga := {
# 		"alertMessage": sprintf("Workload %v does have zero Kubearmor policy", [pod.metadata.name]),
# 		"packagename": "armo_builtins",
# 		"alertScore": 7,
# 		"failedPaths": [],
# 		"fixPaths": [],
# 		"alertObject": {
# 			"k8sApiObjects": [pod]
# 		}
# 	}
# }

check_zerotrust(wlconfig, kubearmorpolicie) {
	some i
	wlpolicie := wlconfig.spec.workloads[i].policies[_]
	kubearmorpolicie.metadata.name == wlpolicie.name
}

# deny[msga] {

#         pods := [p | p = input[_]; p.kind == "Deployment"]
#         pod := pods[_]

# 		workloads := [w |  w= input[_]; w.kind == "WorkloadConfig"]
#         work := workloads[_]

# 		kubearmorpolicies := [kubearmorpolicie |  kubearmorpolicie= input[_]; kubearmorpolicie.kind == "KubeArmorPolicy"]
#         labels_match(work, pod)
# 		kubearmor_policies_connected_to_pod := [kubearmorpolicie |  kubearmorpolicie= kubearmorpolicies[_];  wlConnectedToKubeArmorPolicy(pod, kubearmorpolicie)]
# 		count(kubearmor_policies_connected_to_pod)  0
# 	    # goodPolicies := [goodpolicie |  goodpolicie= kubearmor_policies_connected_to_pod[_];  sensitiveAssetsDirProtected(pod, goodpolicie)]
# 	    # count(goodPolicies) < 1

#         msga := {
# 		"alertMessage": sprintf("Workload %v does have Least Permissive Policies for sensitive assets", [pod.metadata.name]),
# 		"packagename": "armo_builtins",
# 		"alertScore": 7,
# 		"failedPaths": [],
# 		"fixPaths": [],
# 		"alertObject": {
# 			"k8sApiObjects": [pod]
# 		}
# 	}
# }
# Function to check if labels match between work_list and pod
labels_match(work, pod) {
      some i
	  some key,value in work.spec.workloads[i].labels
      pod.spec.selector.matchLabels[key] == value
}

wlConnectedToKubeArmorPolicy(wl, kubearmorpolicie){
    count(kubearmorpolicie.spec.selector.matchLabels) == 0
}


wlConnectedToKubeArmorPolicy(wl, kubearmorpolicie){
	count(kubearmorpolicie.spec.selector.matchLabels) > 0
    count({x | kubearmorpolicie.spec.selector.matchLabels[x] == wl.spec.template.metadata.labels[x]}) == count(kubearmorpolicie.spec.selector.matchLabels)
}

# sensitiveAssetsDirProtected(wlconfig, kubearmorpolicie) {
# 	some i
# 	some j
# 	endswith(wlconfig.spec.workloads[i].sensitive_asset_locations[j], "/")
# 	asset := wlconfig.spec.workloads[i].sensitive_asset_locations[j]
# 	some k
# 	kubearmorpolicie.spec.matchDirectories[k].dir == asset
# }

# sensitiveAssetsPathProtected(wlconfig, kubearmorpolicie) {
# 	not sensitiveAssetsDirProtected(wlconfig, kubearmorpolicie)
# }




