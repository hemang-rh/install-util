REGION := east
GPU := true

.PHONY: create-cluster
create-cluster:
	@if [ -z "$(CLUSTERNAME)" ]; then echo "CLUSTERNAME is not set"; exit 1; fi
	@if [ -z "$(BASEDOMAIN)" ]; then echo "BASEDOMAIN is not set"; exit 1; fi
	@echo "Creating cluster '$(CLUSTERNAME)' in region '$(REGION)' with GPU '$(GPU)'"
	./openshift/create_cluster.sh -c $(CLUSTERNAME) -b $(BASEDOMAIN) -r $(REGION) -g $(GPU)

.PHONY: destroy-cluster
destroy-cluster:
	@if [ -z "$(CLUSTERNAME)" ]; then echo "CLUSTERNAME is not set"; exit 1; fi
	./openshift/destroy_cluster.sh -c $(CLUSTERNAME)

.PHONY: install-rhoai-imperative
install-rhoai-imperative:
	./rhoai/install_rhoai_imperative.sh

.PHONY: install-rhoai-declarative
install-rhoai-declarative:
	./rhoai_declarative/install_rhoai_declarative.sh -g $(GPU)